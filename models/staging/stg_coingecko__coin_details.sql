{{ config(materialized='view') }}

with source as (

    select * from {{ source('coingecko', 'raw_coin_details') }}

),

renamed as (

    select
        lower(coin_id)              as coin_id,
        upper(symbol)               as coin_symbol,
        trim(name)                  as coin_name,
        trim(description)           as coin_description,
        cast(genesis_date as date)  as coin_genesis_date,
        trim(categories)            as coin_categories_raw
    from source

)

select * from renamed