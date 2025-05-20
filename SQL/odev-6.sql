--1

with ads as (
	select
		f.ad_date ,
		f.url_parameters,
		f.spend,
		f.impressions,
		f.reach,
		f.clicks,
		f.leads,
		f.value
	from facebook_ads_basic_daily f
	union  
select
	g.ad_date,
	g.url_parameters,
	g.spend,
	g.impressions,
	g.reach,
	g.clicks,
	g.leads,
	g.value
from google_ads_basic_daily g
)

select
	ad_date,
	url_parameters,
	coalesce(spend, 0) as spend,
	coalesce(impressions, 0) as impressions,
	coalesce(reach, 0) as reach,
	coalesce(clicks, 0) as clicks,
	coalesce(leads, 0) as leads,
	coalesce(value, 0) as value
from ads
where ad_date is not null

--===========================================================================================
--2 ve ek görev
--===========================================================================================


 with ads as (
	select
		f.ad_date ,
		f.url_parameters,
		f.spend,
		f.impressions,
		f.reach,
		f.clicks,
		f.leads,
		f.value
	from facebook_ads_basic_daily f
	union  
select
	g.ad_date,
	g.url_parameters,
	g.spend,
	g.impressions,
	g.reach,
	g.clicks,
	g.leads,
	g.value
from google_ads_basic_daily g
), temp as (

select 
	ad_date,
	coalesce(spend, 0) as spend,
	coalesce(impressions, 0) as impressions,
	coalesce(reach, 0) as reach,
	coalesce(clicks, 0) as clicks,
	coalesce(leads, 0) as leads,
	coalesce(value, 0) as value,
	lower(split_part(substring(substring(url_parameters from position('utm_campaign=' in url_parameters)), length('utm_campaign=')+1), '&', 1)) as utm_campaign 
		 
from ads a) 
select 
	case
		utm_campaign 
		when 'nan' then null
		when '' then null
		else urldecode_arr(utm_campaign)
	end,
	ad_date,
	sum(spend) as spend_sum,
	sum(impressions) as impressions_sum,
	sum(clicks) as clicks_sum,
	sum(value) as value_sum,
	case sum(impressions)
		when 0 then null
		else round(sum(clicks)::numeric / sum(impressions)*100, 2) 
	end  as ctr,
	case sum(clicks)
		when 0 then null
		else round(sum(spend)::numeric / sum(clicks), 2) 
	end  as cpc,
	case sum(clicks)
		when 0 then null
		else round(sum(spend)::numeric / sum(clicks)*1000, 2) 
	end  as cpm,
	case sum(spend)
		when 0 then null
		else round((sum(value)-sum(spend))::numeric / sum(spend)*100, 2) 
	end  as romi 
from temp
where ad_date is not null --tarihsiz boş sütürler
group by utm_campaign, ad_date
order by ad_date;



CREATE OR REPLACE FUNCTION urldecode_arr(url text)
  RETURNS text AS
$BODY$
DECLARE ret text;

BEGIN
 BEGIN

    WITH STR AS (
      SELECT
      
      -- array with all non encoded parts, prepend with '' when the string start is encoded
      case when $1 ~ '^%[0-9a-fA-F][0-9a-fA-F]' 
           then array[''] 
           end 
      || regexp_split_to_array ($1,'(%[0-9a-fA-F][0-9a-fA-F])+', 'i') plain,
      
      -- array with all encoded parts
      array(select (regexp_matches ($1,'((?:%[0-9a-fA-F][0-9a-fA-F])+)', 'gi'))[1]) encoded
    )
    SELECT  string_agg(plain[i] || coalesce( convert_from(decode(replace(encoded[i], '%',''), 'hex'), 'utf8'),''),'')
    FROM STR, 
      (SELECT  generate_series(1, array_upper(encoded,1)+2) i FROM STR)blah

    INTO ret;


  EXCEPTION WHEN OTHERS THEN  
    raise notice 'failed: %',url;
    return $1;
  END;   

  RETURN coalesce(ret,$1); 
END;

$BODY$
  LANGUAGE plpgsql IMMUTABLE STRICT
  
  