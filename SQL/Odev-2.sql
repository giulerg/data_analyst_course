--1

select
	ad_date,
	campaign_id
from
	facebook_ads_basic_daily;

--2

select 
	ad_date,
	campaign_id,
	sum(spend) as toplam_maliyet,
	sum(impressions) as gösterim_sayısı,
	sum(clicks) as tıklama_sayısı,
	sum(value) as total_value_değeri
from
	facebook_ads_basic_daily
where campaign_id is not null
group by
	ad_date,
	campaign_id;


--3

select 
	ad_date,
	campaign_id,
	round((sum(spend))::numeric / sum(clicks), 2) as cpc,
	round((sum(spend))::numeric / sum(impressions)*1000, 2) as cpm,
	round((sum(clicks))::numeric / sum(impressions)*100, 2) as ctr,
	round(((sum(value))::numeric - sum(spend))/sum(spend)*100, 2) as romi
from
	facebook_ads_basic_daily
where
	clicks > 0
group by 
	ad_date,
	campaign_id;

--ek
select 
	id 
from (

	select 
		campaign_id as id,
		sum(spend) as total_spend,
		round(((sum(value))::numeric - sum(spend))/sum(spend)*100, 2) as romi
	from  
		 facebook_ads_basic_daily
	group by  
		campaign_id
	having 
		sum(spend) > 500000
	order by romi desc
	limit 1
) as t;

	