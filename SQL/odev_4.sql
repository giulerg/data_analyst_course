/*
	1. CTE kullanarak bir SQL sorgusunda 
	facebook_ads_basic_daily, facebook_adset ve facebook_campaign tablolarındaki
	 verileri birleştirerek aşağıdakileri içeren bir tablo elde edin:
	ad_date - Facebook'taki reklamın tarihi
	campaign_name - Facebook kampanyasının adı
	adset_name - Facebook reklam setinin adı
	spend, impressions, reach, clicks, leads, value - ilgili günlerdeki kampanyaların ve reklam setlerinin metrikleri
*/

with temp_data as (
select
	d.*,
	c.campaign_name,
	a.adset_name
from
	facebook_ads_basic_daily d
inner join facebook_adset a on
	d.adset_id = a.adset_id
inner join facebook_campaign c on
	d.campaign_id = c.campaign_id 

)

select
	ad_date,
	campaign_name,
	adset_name,
	spend,
	impressions,
	reach,
	clicks,
	leads,
	value
from
	temp_data;


/*2. İkinci CTE'de, google_ads_basic_daily tablosundaki ve 
 * ilk CTE'deki verileri birleştirerek Facebook ve Google 
 * pazarlama kampanyaları hakkında bilgi içeren tek bir tablo elde edin.
*/


with facebook as (
select
	d.*,
	c.campaign_name,
	a.adset_name
from
	facebook_ads_basic_daily d
inner join facebook_adset a on
	d.adset_id = a.adset_id
inner join facebook_campaign c on
	d.campaign_id = c.campaign_id 

),

temp as (
select
	ad_date,
	campaign_name,
	adset_name,
	spend,
	impressions,
	reach,
	clicks,
	leads,
	value
from
	facebook f
	
union all

select
	ad_date,
	campaign_name,
	adset_name,
	spend,
	impressions,
	reach,
	clicks,
	leads,
	value
from
	google_ads_basic_daily g

)

select * from temp;

/*3*/
with facebook as (
select
	d.*,
	c.campaign_name,
	a.adset_name
from
	facebook_ads_basic_daily d
inner join facebook_adset a on
	d.adset_id = a.adset_id
inner join facebook_campaign c on
	d.campaign_id = c.campaign_id 

),

temp as (
select
	ad_date,
	campaign_name,
	'Facebook' as media_source,
	adset_name,
	spend,
	impressions,
	reach,
	clicks,
	leads,
	value
from
	facebook f
	
union all

select
	ad_date,
	campaign_name,
	'Google' as media_source,
	adset_name,
	spend,
	impressions,
	reach,
	clicks,
	leads,
	value
from
	google_ads_basic_daily g

)

select
	ad_date,
	media_source,
	campaign_name,
	adset_name,
	sum(spend) as toplam_maliyet_miktarı,
	sum(impressions) as gösterim_sayısı,
	sum(clicks) as tıklama_sayısı,
	round((sum(clicks)::numeric) / sum(impressions) * 100, 2) as toplam_dönüşüm_değeri
from
	temp
group by
	ad_date,
	media_source,
	campaign_name,
	adset_name
having
	sum(impressions) > 0;


/*
 * Dört tablodaki verileri birleştirerek, 
 * toplam harcaması 500.000'den fazla olan 
 * tüm kampanyalar arasında en yüksek ROMI'ye sahip kampanyayı belirleyin.
 */



with temp as (
select
	c.campaign_name,
	a.adset_name,
	d.spend,
	d.value
from
	facebook_ads_basic_daily d
inner join facebook_adset a on
	d.adset_id = a.adset_id
inner join facebook_campaign c on
	d.campaign_id = c.campaign_id 
union all
select
	campaign_name,
	adset_name,
	spend,
	value
from
	google_ads_basic_daily g

)
select
	campaign_name,
	round((sum(value) - sum(spend))::numeric / sum(spend) * 100, 2) as romi
from
	temp
group by
	campaign_name
having
	sum(spend) > 500000
order by
	romi desc
limit 1

/* 
	Bu kampanya içinde, en yüksek ROMI'ye sahip reklam grubunu (adset_name) belirleyin
*/
with temp as (
	select
		c.campaign_name,
		a.adset_name,
		d.spend,
		d.value
	from
		facebook_ads_basic_daily d
	inner join facebook_adset a on
		d.adset_id = a.adset_id
	inner join facebook_campaign c on
		d.campaign_id = c.campaign_id
	union all
	select
		campaign_name,
		adset_name,
		spend,
		value
	from
		google_ads_basic_daily g

),

high_romi as (
	select
		campaign_name,
		round((sum(value) - sum(spend))::numeric / sum(spend) * 100, 2) as romi
	from temp
	group by campaign_name
	having sum(spend) > 500000
	order by romi desc
	limit 1
)
select
	adset_name, 
	round((sum(value) - sum(spend))::numeric / sum(spend) * 100, 2) as romi
from
	temp
where
	campaign_name = (
	select campaign_name
	from high_romi)
group by adset_name
order by romi desc
limit 1