--1
with google as (select 
	ad_date,
	'Google Ads' as media_source,
	spend,
	impressions,
	reach,
	clicks,
	leads,
	value
from
	google_ads_basic_daily),
	
facebook as (
select 
	ad_date,
	'Facebook Ads' as media_source,
	spend,
	impressions,
	reach,
	clicks,
	leads,
	value
from
	facebook_ads_basic_daily)	
select * from google
union 
select * from facebook;


--2
with google as (select 
	ad_date,
	'Google Ads' as media_source,
	spend,
	impressions,
	reach,
	clicks,
	leads,
	value
from
	google_ads_basic_daily),
	
facebook as (
select 
	ad_date,
	'Facebook Ads' as media_source,
	spend,
	impressions,
	reach,
	clicks,
	leads,
	value
from
	facebook_ads_basic_daily),
	
all_ads as (
	select * from google
	union 
	select * from facebook)
	
select
	ad_date,
	media_source,
	sum(spend) as toplam_maliyet,
	sum(impressions) as gösterim_sayısı,
	sum(clicks) as tıklama_sayısı,
	round((sum(clicks))::numeric/sum(impressions)*100, 2) as toplam_dönüşüm_değeri
from
	all_ads
where impressions > 0
group by
	ad_date,
	media_source ;