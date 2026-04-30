-- E-commerce User & Email Analytics
-- Combines account and email metrics
-- Includes segmentation, ranking, and time-based analysis

--CTE to calculate account information by date, country, and subscriber parameters
with account_info as (
select
s.date,
sp.country as country,
ac.send_interval as send_interval,
ac.is_verified as is_verified,
ac.is_unsubscribed as is_unsubscribed,
count (distinct ac.id) as account_cnt,    
  
0 as sent_msg,
0 as open_msg,
0 as visit_msg
  
from `DA.account` ac
join `DA.account_session` acs
on ac.id = acs.account_id
join `DA.session_params` sp
on acs.ga_session_id = sp.ga_session_id
join `DA.session` s
on s.ga_session_id = sp.ga_session_id
group by s.date, sp.country, ac.send_interval, ac.is_verified, ac.is_unsubscribed
),

--CTE for calculating email metrics by account
email_info as (
select
date_add(s.date, interval es.sent_date day) as date,
sp.country,
ac.send_interval,
ac.is_verified,
ac.is_unsubscribed,
0 as account_cnt,
count(distinct es.id_message) as sent_msg,
count(distinct eo.id_message) as open_msg,
count(distinct ev.id_message) as visit_msg
   
from `DA.email_sent` es
left join `DA.email_open` eo
on es.id_message = eo.id_message and  es.id_account = eo.id_account
left join `DA.email_visit` ev
on es.id_message = ev.id_message and es.id_account = ev.id_account

join `DA.account` ac
on es.id_account = ac.id
join `DA.account_session` acs
on ac.id = acs.account_id
join `DA.session` s
on acs.ga_session_id = s.ga_session_id
join `DA.session_params` sp
on s.ga_session_id = sp.ga_session_id
group by date_add(s.date, interval es.sent_date day), sp.country, ac.send_interval, ac.is_verified, ac.is_unsubscribed
),

union_all as (
select * from account_info
union all
select * from email_info
),

--Aggregation of metrics by sections
aggregated as (
select
date,
country,
send_interval,
is_verified,
is_unsubscribed,
sum(account_cnt) as account_cnt,
sum(sent_msg) as sent_msg,
sum(open_msg) as open_msg,
sum(visit_msg) as visit_msg
from union_all
group by date, country, send_interval, is_verified, is_unsubscribed
),

--CTE for calculating overall indicators by country
country_totals as (
select *,
sum(account_cnt) over (partition by country) as total_country_account_cnt,
sum(sent_msg) over (partition by country) as total_country_sent_cnt
from aggregated
),

--Ranking
ranked as (
select *,
dense_rank() over (order by total_country_account_cnt desc) as rank_total_country_account_cnt,
dense_rank() over (order by total_country_sent_cnt desc) as rank_total_country_sent_cnt
from country_totals
)

--Final result
select *
from ranked
where rank_total_country_account_cnt <= 10 or rank_total_country_sent_cnt <=10
