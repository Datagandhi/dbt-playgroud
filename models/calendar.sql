select  *from ao_gold_sales_commercial.mvp.dimcalendar where PYYTDFYReporting = 1;





with
    calendardatesgenerated as (
        select
            dateadd(
                'day', row_number() over (order by 1) - 1, '2000-01-01'::date
            ) as calendardate
        from table(generator(rowcount => 18263))  -- generates dates from 2000-01-01 to 2050-01-01
    ),
    currentdates as (
        select
            current_date as currentdate,
            currentdate - 1 as yesterday,
            date_trunc(week, currentdate) as currentweek,
            date_trunc(month, currentdate) as currentmonth,
            date_trunc(quarter, currentdate) as currentquarter,
            date_trunc(year, currentdate) as currentyear,
            dateadd(week, -1, currentweek) as lastweek,
            dateadd(month, -1, currentmonth) as lastmonth,
            dateadd(quarter, -1, currentquarter) as lastquarter,
            dateadd(year, -1, currentyear) as lastyear,
            dateadd(week, -1, currentdate) as lastweekwtd,
            dateadd(month, -1, currentdate) as lastmonthmtd,
            dateadd(quarter, -1, currentdate) as lastquarterqtd,
            dateadd(year, -1, currentdate) as lastyearytd,
            dateadd(day, 1, dateadd(year, -1, currentdate)) as pycurrentdate
    ),
    fiscaldates as (
        select
            calendardate as fiscaldate,
            year(dateadd(month, -3, calendardate)) + 1 fiscalyear,
            mod(month(calendardate) + 8, 12) + 1 as fiscalmonth,
            quarter(dateadd(month, -3, calendardate)) as fiscalquarter,
            week(dateadd(month, -3, calendardate)) as fiscalweekno,
            concat('Q', fiscalquarter, ' ', fiscalyear) as fiscalyearquarter,
            concat(fiscalyear, fiscalquarter)::int as fiscalquarteryearsort,
            concat(fiscalmonth, ' ', fiscalyear) as fiscalmonthyear,
            concat(
                fiscalyear,
                case
                    when fiscalmonth >= 10
                    then fiscalmonth::varchar
                    else concat(0, fiscalmonth::varchar)
                end
            )::int as fiscalmonthyearsort,
            date_trunc(week, dateadd(month, -3, fiscaldate)) as fiscalweekstartdate,
            date_trunc(month, dateadd(month, -3, fiscaldate)) as fiscalmonthstartdate,
            date_trunc(
                quarter, dateadd(month, -3, fiscaldate)
            ) as fiscalquarterstartdate,
            date_trunc(year, dateadd(month, -3, fiscaldate)) as fiscalyearstartdate
        from calendardatesgenerated
    ),
    calendardates as (
        select
            calendardate as date,
            replace(calendardate, '-', '') as datekey,
            to_char(calendardate, 'MON') as calendarmonthshort,
            to_char(calendardate, 'MMMM') as calendarmonthlong,
            dayname(calendardate) as calendardayname,
            year(calendardate) as calendaryear,
            quarter(calendardate) as calendarquarter,
            month(calendardate) as calendarmonth,
            weekiso(calendardate) as calendarweekno,
            to_char(calendardate, 'MON YYYY') as calendarmonthyear,
            left(datekey, 6)::int as calendarmonthyearsort,
            concat('Q', calendarquarter, ' ', calendaryear) as calendarquarteryear,
            concat(calendaryear, calendarquarter) as calendarquarteryearsort,
            dayofweekiso(calendardate) calendardayofweek,
            dayofmonth(calendardate) as calendardayofmonth,
            dayofyear(calendardate) as calendardayofyear,
            fiscalyearquarter,
            fiscalquarteryearsort,
            fiscalmonthyear,
            fiscalmonthyearsort,
            case
                when day(calendardate) = 29 and calendarmonth = 2 then 1 else 0
            end as isleapday,
            to_number(
                mod(calendaryear, 4) = 0
                and (mod(calendaryear, 100) != 0 or mod(calendaryear, 400) = 0)
            ) isleapyear,
            date_trunc(week, calendardate) as calendarweekstartdate,
            date_trunc(month, calendardate) as calendarmonthstartdate,
            date_trunc(quarter, calendardate) as calendarquarterstartdate,
            date_trunc(year, calendardate) as calendaryearstartdate,
            case when calendardate = currentdate then 1 else 0 end as iscurrentday,
            case
                when calendardate >= currentweek and calendardate <= currentdate
                then 1
                else 0
            end as iscurrentwtd,
            case
                when calendardate >= date_trunc(week, currentdate-1) and calendardate <= currentdate - 1
                then 1
                else 0
            end as iscurrentwtdreporting,
            case
                when calendardate >= lastweek and calendardate <= lastweekwtd
                then 1
                else 0
            end as islastweekwtd,
            case
                when calendardate >= currentmonth and calendardate <= currentdate
                then 1
                else 0
            end as iscurrentmtd,
            case
                when calendardate >= date_trunc(month, currentdate-1) and calendardate <= currentdate - 1
                then 1
                else 0
            end as iscurrentmtdreporting,
            case
                when calendardate >= lastmonth and calendardate <= lastmonthmtd
                then 1
                else 0
            end as islastmonthmtd,
            case
                when calendardate >= currentquarter and calendardate <= currentdate
                then 1
                else 0
            end as iscurrentqtd,
            case
                when calendardate >= lastquarter and calendardate <= lastquarterqtd
                then 1
                else 0
            end as islastquarterqtd,
            case
                when calendardate >= currentyear and calendardate <= currentdate
                then 1
                else 0
            end as iscurrentytd,
            case
                when
                    calendardate >= f.fiscalweekstartdate
                    and calendardate <= currentdate
                then 1
                else 0
            end as isfiscalwtd,
            case
                when
                    calendardate >= f.fiscalmonthstartdate
                    and calendardate <= currentdate
                then 1
                else 0
            end as isfiscalmtd,
            case
                when
                    calendardate >= f.fiscalquarterstartdate
                    and calendardate <= currentdate
                then 1
                else 0
            end as isfiscalqtd,
            case
                when
                    calendardate >= f.fiscalyearstartdate
                    and calendardate <= currentdate
                then 1
                else 0
            end as isfiscalytd,
            case
                when calendarweekstartdate = currentweek then 1 else 0
            end as iscurrentweek,
            case
                when calendarmonthstartdate = currentmonth then 1 else 0
            end as iscurrentmonth,
            case
                when calendarquarterstartdate = currentquarter then 1 else 0
            end as iscurrentquarter,
            case
                when calendaryearstartdate = currentyear then 1 else 0
            end as iscurrentyear,
            case
                when
                    calendardate >= dateadd(month, 3, lastyear)
                    and calendardate <= currentdate - 1
                then 1
                else 0
            end as iscurrentytdfyreporting,
            case when calendardate = yesterday then 1 else 0 end as ispreviousday,
            case
                when calendarweekstartdate = lastweek then 1 else 0
            end as ispreviousweek,
            case
                when calendarmonthstartdate = lastmonth then 1 else 0
            end as ispreviousmonth,
            case
                when calendarquarterstartdate = lastquarter then 1 else 0
            end as ispreviousquarter,
            case
                when calendaryearstartdate = lastyear then 1 else 0
            end as ispreviousyear,
            case
                when
                    calendardate >= dateadd(month, 3, lastyear)
                    and calendardate <= lastyearytd
                then 1
                else 0
            end as pyytdfy,
            case
                when
                    calendardate >= dateadd(month, 3, lastyear)
                    and calendardate <= lastyearytd - 1
                then 1
                else 0
            end as pyytdfyyesterday,
            case
                when calendardayofweek in (1, 2, 3, 4, 5) then 1 else 0
            end as isweekday,
            case when calendardayofweek in (6, 7) then 1 else 0 end as isweekend,
            case
                when
                    calendardate = dateadd(
                        day,
                        28,
                        dateadd(
                            day,
                            (5 - dayofweek(date_from_parts(calendaryear, 11, 1))),
                            date_from_parts(calendaryear, 11, 1)
                        )
                    )
                then 1
                else 0
            end as isblackfriday,
            case when bh."Date" is not null then 1 else 0 end as isbankholiday,
            dateadd(day, 1, dateadd(year, -1, currentdate)) as pycurrentdate,
            date_trunc(week, pycurrentdate) as pycurrentweek,
            date_trunc(month, pycurrentdate) as pycurrentmonth,
            date_trunc(quarter, pycurrentdate) as pycurrentquarter,
            date_trunc(year, pycurrentdate) as pycurrentyear,
            case when calendardate = pycurrentdate then 1 else 0 end as pycurrentday,
            case
                when calendardate = dateadd(day, 1, dateadd(year, -1, currentdate - 1))
                then 1
                else 0
            end as pycurrentdayreporting,
            case
                when calendardate >= pycurrentweek and calendardate <= pycurrentdate
                then 1
                else 0
            end as pycurrentwtd,
            case
                when calendardate >= pycurrentweek and calendardate <= pycurrentdate - 1
                then 1
                else 0
            end as pycurrentwtdreporting,
            case
                when calendardate >= pycurrentmonth and calendardate <= pycurrentdate
                then 1
                else 0
            end as pycurrentmtd,
            case
                when
                    calendardate >= pycurrentmonth and calendardate <= pycurrentdate - 2
                then 1
                else 0
            end as pycurrentmtdreporting,
            case
                when calendardate >= pycurrentquarter and calendardate <= pycurrentdate
                then 1
                else 0
            end as pycurrentqtd,
            case
                when
                    calendardate >= pycurrentquarter
                    and calendardate <= pycurrentdate - 1
                then 1
                else 0
            end as pycurrentqtdreporting,
            case
                when calendardate >= pycurrentyear and calendardate <= pycurrentdate
                then 1
                else 0
            end as pycurrentytd,
            case
                when
                    calendardate >= dateadd(month, 3, lastyear)
                    and calendardate <= lastyearytd - 1
                then 1
                else 0
            end as pyytdfyreporting,
            case
                when
                    calendardate >= dateadd(day, -6, currentdate)
                    and calendardate <= currentdate
                then 1
                else 0
            end as islast7days,
            case
                when
                    calendardate >= dateadd(day, -13, currentdate)
                    and calendardate <= currentdate
                then 1
                else 0
            end as islast14days,
            case
                when
                    calendardate >= dateadd(day, -27, currentdate)
                    and calendardate <= currentdate
                then 1
                else 0
            end as islast28days,
            case when calendardate = lastyearytd then 1 else 0 end as islydate,
            case
                when
                    calendardate = lastyearytd and calendardayofweek = calendardayofweek
                then 1
                else 0
            end as islydow,
            case
                when
                    calendardate = lastyearytd
                    and calendardayofweek <= calendardayofweek
                then 1
                else 0
            end as islywtd,
            case
                when
                    calendardate = lastyearytd
                    and calendardayofmonth <= calendardayofmonth
                then 1
                else 0
            end as islymtd
        from calendardatesgenerated d
        left join fiscaldates f on d.calendardate = f.fiscaldate
        left join
            "AO_SILVER_SALES_COMMERCIAL"."MVP"."BankHolidays" bh
            on d.calendardate = bh."Date"
        cross join currentdates
    )
select *
from calendardates
where pyytdfyreporting = 1