--------------------------------     SkillBridge Sales Operations Analytics-----------------------------------------------

create database SkillBridgeAnalytics;
----------------------------------------------------------------------------------------------------------------------
-----                                Data Profiling
----------------------------------------------------------------------------------------------------------------------
----- Structure — confirm every column's data type 
select
      TABLE_NAME, 
      COLUMN_NAME, 
      DATA_TYPE, 
      CHARACTER_MAXIMUM_LENGTH, 
      IS_NULLABLE
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME IN 
    ('DimDate','DimSalesRep','DimProduct','DimLeadSource','DimLostReason',
     'FactLeads','DimCustomer','FactSales','FactCRMActivities','FactTargets')
order by TABLE_NAME, ORDINAL_POSITION;
----- Row counts — all tables, one query
select 'DimDate' as tbl, count (*) as n from DimDate
union all select 'DimSalesRep', count (*) from DimSalesRep
union all select 'DimProduct', count (*) from DimProduct
union all select 'DimLeadSource', count(*) from DimLeadSource
union all select 'DimLostReason', count(*) from DimLostReason
union all select 'FactLeads', count(*) from FactLeads
union all select 'DimCustomer', count(*) from DimCustomer
union all select 'FactSales', count(*) from FactSales
union all select 'FactCRMActivities', count(*) from FactCRMActivities
union all select'FactTargets', count(*) from FactTargets;
----- FactLeads — content shape
select 
      count(*) as total_rows,
      count(phone) as phone_present,
      count(*) - count(phone) as phone_missing,
      count(email) as email_present,
      count(*) - count(email) as email_missing,
      count(assigned_rep_id) as assigned,
      count(distinct status) as distinct_statuses,
      count(distinct source_raw) as distinct_source_raw_values,
      count(distinct location_raw) as distinct_location_raw_values,
      min(lead_date) as earliest_lead,
      max(lead_date) as latest_lead
from FactLeads;
-----------------------------------------------------------------------------------------------------------------------------------
-----                                  FactLeads Data Quality Checks                                             -----
-----                  FactLeads - Content Shape: Checking for missing values, distinct values, and date ranges
select 
      count(*) as total_rows,
      count(phone) as phone_present,
      count(*) - count(phone) as phone_missing,
      count(email) as email_present,
      count(*) - count(email) as email_missing,
      count(assigned_rep_id) as assigned,
      count(*) - count(assigned_rep_id) as unassigned,
      count(distinct status) as distinct_statuses,
      count(distinct source_raw) as distinct_source_raw_values,
      count(distinct location_raw) as distinct_location_raw_values,
      min(lead_date) as earliest_lead,
      max(lead_date) as latest_lead
from FactLeads;
----- DimCustomer: checking for duplicate profiles and phone/email gaps
select
     count(*) as total_rows,
     count(distinct customer_id) as distinct_ids,
     count(phone) as phone_present,
     count(email) as email_present,
     count(distinct segment) as distinct_segments
from DimCustomer;
----- FactSales — check for the injected outlier revenue values and payment split
select
      count(*) as total_rows,
      min(amount_paid_ngn) as min_paid,
      max(amount_paid_ngn) as max_paid, 
      avg(amount_paid_ngn) as avg_paid,
      sum(case when payment_status= 'Partial' then 1 else 0 end) as partial_paymets,
      sum(case when amount_paid_ngn < 0.2*list_price_ngn then 1 else 0 end) as suspiciously_low_payments
from FactSales;
----- FactCRMActivities — check the zero-activity and over-activity outliers
select
      activity_type,
      count(*) as n
from FactCRMActivities
group by activity_type
order by n desc;
----- Funnel shape
select 
      status,
      count(*) as n
from FactLeads
     group by status
     order by n desc;
----- FactLeads lost reasons completeness
select
      sum(case when status='Lost' then 1 else 0 end) as total_lost,
      sum(case when status='Lost' and lost_reason is null then 1 else 0 end) as lost_no_reason
from FactLeads;
----- How messy is source_raw, really?
select distinct source_raw
from FactLeads
Order by source_raw; 
----- Same for location
select distinct location_raw
from FactLeads
order by location_raw; 
----- Missing values check
select 
      sum(case when phone is null then 1 else 0 end) as missing_phone,
      sum(case when email is null then 1 else 0 end) as missing_email,
      sum(case when assigned_rep_id is null then 1 else 0 end) as unassignment
from FactLeads;

-----                                  FactSales Data Quality Checks                         -----
----- Checking FactSales for missing values in critical column
select
    count(*) as total_sales,
    count(sale_id) as sales_with_id,
    count(lead_id) as sales_with_lead,
    count(customer_id) as sales_with_customer,
    count(rep_id) as sales_with_rep,
    count(product_id) as sales_with_product,
    count(sale_date) as sales_with_date,
    count(list_price_ngn) as sales_with_list_price,
    count(amount_paid_ngn) as sales_with_payment
from FactSales;
----- Validating FactSales for duplicate sale_id entries
select
    sale_id,
    count(*) as order_count
from FactSales
group by sale_id
having count (*) > 1;
----- Investigating how list_price_ngn and amount_paid_ngn
select
    count(*) as sales_below_list_price,
    sum(case
            when amount_paid_ngn < list_price_ngn then 1
            else 0
        end) as partial_or_underpaid,
    sum(case
            when amount_paid_ngn = list_price_ngn then 1
            else 0
        end) AS fully_paid,
    sum(case
            when amount_paid_ngn > list_price_ngn then 1
            else 0
        end) as paid_above_list_price
from FactSales;
----- FactSales records where amount_paid_ngn is greater than list_price_ngn
select
    sale_id,
    lead_id,
    customer_id,
    product_id,
    list_price_ngn,
    amount_paid_ngn
from FactSales
where amount_paid_ngn > list_price_ngn;
----- Financial summary of FactSales: minimum, maximum, and average values for amount_paid_ngn and list_price_ngn
select
    min(amount_paid_ngn) as minimum_paid,
    max(amount_paid_ngn) as maximum_paid,
    avg(amount_paid_ngn) as average_paid,
    min(list_price_ngn) as minimum_list_price,
    max(list_price_ngn) as maximum_list_price,
    avg(list_price_ngn) as average_list_price
from FactSales;
----- Validating FactSales for sales records that do not have a corresponding lead record in FactLeads
select
      count(*) as sales_without_leads
from FactSales fs
left join FactLeads fl
on fs.lead_id = fl.lead_id
where fl.lead_id is null;
----- Does every customer referenced in FactSales actually exist in DimCustomer?
select
       count(*) as sales_without_customers
from FactSales fs
left join DimCustomer dc
on fs.customer_id = dc.customer_id
where dc.customer_id is null;
----- Checking if every sales representative referenced in FactSales actually exists in DimSalesRep
select
      count(*) as sales_without_reps
from FactSales fs
left join DimSalesRep dsr
on fs.rep_id = dsr.rep_id
where dsr.rep_id is null;
----- 
select
      count(*) as sales_without_matching_product
from FactSales fs
left join DimProduct dp
on fs.product_id = dp.product_id
where dp.product_id is null;

-----                             FactCRMActivities Data Quality Checks                             
select 
       count(*) as total_activities,
       count(activity_id) as activities_with_id,
       count(lead_id) as activities_with_lead,
       count(rep_id) as activities_with_rep,
       count(activity_date) as activities_with_date,
       count(activity_type) as activities_with_type
from FactCRMActivities;
----- FactCRMActivities duplicate activity_id check
select
      activity_id,
      count(*) as duplicate_activity_id_count
from FactCRMActivities
group by activity_id
having count(*) > 1;
----- FactCRMActivities records where the lead_id does not exist in FactLeads
select
      count(*) as activities_without_leads
from FactCRMActivities fca
left join FactLeads fl
on fca.lead_id = fl.lead_id
where fl.lead_id is null; 
----- Reviewing FactCRMActivities records where the rep_id does not exist in DimSalesRep
select
    count(*) as total_targets,
    count(target_id) as targets_with_id,
    count(rep_id) as targets_with_rep,
    count(target_revenue_ngn) as targets_with_revenue,
    count(target_deals) as targets_with_deals
from FactTargets;
----- FactTargets duplicate target_id check
select
    target_id,
    count(*) AS target_count
from FactTargets
group by target_id
having count(*) > 1;
-----
select
    rep_id,
    year_month,
    count(*) as target_count
from FactTargets
group by
    rep_id,
    year_month
having count(*) > 1;

-----                                  Data Cleaning                                                       ----- 
-----                                  FactLeads Data Cleaning                                             -----
----- 1. Standardization: Mapping tabes 
create table LocationMap (
        raw_value varchar(50) not null primary key,
        clean_value varchar(50) not null
);

insert into LocationMap (raw_value, clean_value) values
('Lagos','Lagos'), ('Lagos State','Lagos'), ('Lagos Nigeria','Lagos'),
('Abuja','Abuja'), ('Abuja (FCT)','Abuja'), ('FCT Abuja', 'Abuja'),
('Port Harcourt','Port Harcourt'), ('PH','Port Harcourt'), ('P/Harcourt','Port Harcourt'),
('Ibadan','Ibadan'),
('Benin','Benin City'), ('BENIN CITY','Benin City'), ('Benin-City','Benin City'),
('Enugu','Enugu'),
('Kaduna','Kaduna'), ('Kaduna State','Kaduna'),
('Kano', 'Kano'), ('Kano State','Kano');

create table SourceMap (
       raw_value varchar(50) not null primary key,
       clean_value varchar(50) not null
);

insert into SourceMap (raw_value, clean_value) values
('GOOGLE ADS','Google Ads'), ('Google','Google Ads'), ('GAds','Google Ads'), ('GOOGLE ADWORDS','Google Ads'),
('FACEBOOK','Facebook/Instagram Ads'), ('Facebook Ads','Facebook/Instagram Ads'),
('FACEBOOK/INSTAGRAM ADS','Facebook/Instagram Ads'), ('FB/IG Ads','Facebook/Instagram Ads'),
('Instagram Ads','Facebook/Instagram Ads'), ('IG Ads','Facebook/Instagram Ads'),
('Web','Website'), ('WEBSITE','Website'), ('Website Form','Website'), ('Online Form','Website'),
('Referral Program','Referral'), ('Word of Mouth','Referral'),
('Organic Social','Organic Social Media'), ('organic social media','Organic Social Media'),
('Social Media (Organic)','Organic Social Media'), ('IG Organic','Organic Social Media'), ('Social Ads','Organic Social Media'),
('WALK IN','Walk-in'), ('Walkin','Walk-in'),
('B2B Outreach','Corporate Outreach'), ('Corp Outreach','Corporate Outreach'),
('Corporate','Corporate Outreach'), ('CORPORATE OUTREACH','Corporate Outreach');
----- LocationMap-lm, FactLeads-fl, SourceMap-sm
create view FactLeads_Clean as 
select 
      fl.*,
      coalesce(lm.clean_value, fl.location_clean) as location_final,
      coalesce(sm.clean_value, fl.source_clean, 'Unknown') as source_final
from FactLeads fl
left join LocationMap lm 
     on fl.location_raw = lm.raw_value
left join SourceMap sm
     on fl.source_raw = sm.raw_value;

select top 20
             lead_id, 
             location_raw, 
             location_final, 
             source_raw, 
             source_final
from FactLeads_Clean;
----- Verifying the final location and source final values
select distinct     
                location_final,
                source_final
from            FactLeads_Clean
order by        location_final, source_final;
----- Verifying unmapped location and source values
select
      location_raw,
      location_final,
      source_raw,
      source_final
from
     FactLeads_Clean
where location_final is null
      or source_final is null;

-----  2. Duplicate FactLeads checks: Phone
select
      count(*) as duplicate_phone_groups,
      sum(phone_counts) as duplicate_leads_phone_records,
      sum(phone_counts) - count(*) as excess_duplicate_phone_records
from (
       select 
             phone,
             count(*) as phone_counts
        from FactLeads
        where phone is not null
        group by phone
        having count(*) > 1
    ) as duplicate_phone; -- duplicate_groups (506), leads_records_with_duplicate(1012), excess_duplicate_records(506)
----- Examining duplicate phone
select
    lead_id,
    lead_date,
    phone,
    email,
    source_raw,
    source_clean,
    location_raw,
    location_clean,
    product_interest,
    status,
    sales_ready_date,
    contacted_date,
    closed_date
    lost_reason
from FactLeads
where phone = '09199002772'
order by lead_date;
----- Investigating FactLeads Duplicate Email count, excess records = total records in duplicate groups − number of duplicate groups
select 
       count(*) as duplicate_email_groups,
       sum(email_lead_counts) as duplicate_leads_email_records,
       sum(email_lead_counts) - count(*) as excess_duplicate_email_records
from (
       select 
             email,
             count(*) as email_lead_counts
        from FactLeads
        where email is not null
        group by email
        having count(*) > 1
    ) as duplicate_email; -- duplicate_groups (1146), leads_with_duplicate_email(2389), excess_duplicate_records(1243)
----- Investigating lead records where both the email and phone belong to duplicate groups.
    select
          count(*) as leads_duplicate_phone_and_emails
    from FactLeads
    where phone in (
                     select phone
                     from FactLeads
                     where phone is not null
                     group by phone
                     having count(*) > 1
                  )
    and email in (
                   select email
                   from FactLeads
                   where email is not null
                   group by email
                   having count(*) > 1
                ); -- leads_duplicate_phone_and_emails = 956
----- Investigating records where the same phone AND same email combination appears more than once.
select
    count(*) as duplicate_phone_email_groups,
    sum (record_count) as leads_with_duplicate_phone_email,
    sum (record_count) - count(*) as excess_duplicate_records
from (
       select
             phone,
             email,
             count(*) as record_count
      from FactLeads
      where phone is not null 
          and email is not null
      group by phone, email
      having count(*) > 1
    ) as duplicate_combinations; -- duplicate_phone_email_groups =478, leads_with_duplicate_phone_email=956, excess_duplicate= 478
 ------ Investigating the duplicate phone and email combination records
    select
          fl.lead_id,
          fl.lead_date,
          fl.phone,
          fl.email,
          fl.source_raw,
          fl.location_raw,
          fl.product_interest,
          fl.status,
          fl.sales_ready_date,
          fl.contacted_date,
          fl.closed_date,
          fl.lost_reason
    from FactLeads fl
    where exists (
                   select 1
                   from FactLeads fl2
                   where fl.phone = fl2.phone
                          and fl.email = fl2.email
                          and fl.lead_id <> fl2.lead_id
                )
    order by fl.phone,
             fl.email,
             fl.lead_date;
----- Duplicate checks by program_interest
select
      phone,
      email,
      count(distinct product_interest) as distinct_product_interest
from FactLeads
where phone is not null
       and email is not null
group by phone,
         email
having count(*) > 1;
----- Duplicate Flag
create or alter view FactLeads_cleaned as

with DuplicateCheck as 
(
  select
        fl.*,
        row_number () over(
                            partition by phone, email, product_interest
                            order by lead_date, lead_id
                          ) as duplicate_number
  from FactLeads fl
  where phone is not null
       and email is not null
       and product_interest is not null
)
select
       fl.*,
       case 
        when dc.duplicate_number is null then 'Not Checked'   -- missing phone/email, can't determine
          when dc.duplicate_number = 1 then 'Keep'              -- first occurrence, the original
          else 'Duplicate'                                       -- repeat occurrence
       end as duplicate_flag
from FactLeads fl
left join Duplicatecheck dc 
on fl.lead_id = dc.lead_id;
----- Validating the duplicate flag
select
      duplicate_flag,
      count(*) as lead_count
from FactLeads_cleaned
group by duplicate_flag
order by duplicate_flag;

----- 3. Missing Values Imputation: For missing phone and email, we can use the following approach:
select
      case
          when phone is null and email is null then 'Both Missing'
          when phone is null then 'Phone Missing'
          when email is null then 'Email Missing'
          else 'Neither Missing'
      end as contact_information_status,
      count(*) as lead_count
from FactLeads
group by
        case 
            when phone is null and email is null then 'Both Missing'
            when phone is null then 'Phone Missing'
            when email is null then 'Email Missing'
            else 'Neither Missing'
        end
order by lead_count desc; 
----- Unassigned Sales Representatives
select
      status,
      count(*) as lead_count
from FactLeads
where assigned_rep_id is null
group by status
order by lead_count desc; 
----- Lost leads without a reason
select
      source_clean,
      count(*) as lost_without_reason
from FactLeads
where status = 'Lost'
      and lost_reason is null
group by source_clean
order by lost_without_reason;
----- Investigating missing lost reasons leads
select 
      case
          when sales_ready_date is not null then 'Reached Sales-Ready'
          else 'Did Not Reach Sales-Ready'
     end as funnel_stage,
     count(*) as lead_count
from FactLeads
where status = 'Lost'
      and lost_reason is null
group by 
      case
          when sales_ready_date is not null then 'Reached Sales-Ready'
          else 'Did Not Reach Sales-Ready'
      end;

-----             Data Analytics and Insights Generation     ----------------------------------------------------

----- 1. Lead Conversion Rate Analysis Overall Sales Funnel.
select
      status,
      count(*) as lead_count,
      cast(count(*) * 100.0 / sum(count(*)) over()
           as decimal(5,2)
           ) as lead_percentage
from FactLeads_cleaned 
where duplicate_flag = 'Keep'
group by status
order by lead_count;

----- 2. H1: Lead volume may not equal lead quality--------------------------------------------------
select
      source_clean,
      count(*) as lead_count,
      sum(case when status ='Won' then 1 else 0 end) as won_leads,
      sum(case when sales_ready_date is not null then 1 else 0 end) as sales_ready_leads
from FactLeads_Cleaned
where duplicate_flag = 'Keep'
group by source_clean
order by lead_count desc;

----- 3. H1: Commercial query- Do sources that generate stronger-quality leads also contribute meaningful sales value?
select
      fl.source_clean,
      count(fs.sale_id) as sales_orders,
      sum(fs.amount_paid_ngn) as total_amount_paid,
      avg(fs.amount_paid_ngn) as average_amount_paid
from FactSales fs
inner join FactLeads_Cleaned fl
     on fs.lead_id = fl.lead_id
where fl.duplicate_flag = 'Keep'
group by fl.source_clean
order by total_amount_paid desc;

----- 4. H2: Faster follow-up is associated with higher conversion.--------------------------------------------------------------

----- Investigating the relationship between lead response time and conversion rates (How many days elapsed between lead creation and the first recorded activity?)
----- Analyze Won Rate by Follow-Up Speed
with FirstActivity as(
    select
        lead_id,
        min(activity_date) as first_activity_date
    from FactCRMActivities
    group by lead_id
),
LeadFollowUp as (
    select
        fl.lead_id,
        fl.status,
        datediff(day, fl.lead_date, fa.first_activity_date) as days_to_first_activity
    from FactLeads_Cleaned fl
    inner join FirstActivity fa
        on fl.lead_id = fa.lead_id
    where fl.duplicate_flag = 'Keep'
),
FollowUpBands as (
   select
        *,
       case
            when days_to_first_activity = 0 then 'Same day'
            when days_to_first_activity = 1 then '1 day'
            when days_to_first_activity between 2 and 3 then '2-3 days'
            when days_to_first_activity between 4 and 7 then '4-7 days'
            when days_to_first_activity between 8 and 30 then '8-30 days'
            else '31+ days'
        end as follow_up_speed
    from LeadFollowUp
)
select
    follow_up_speed,
    count(*) AS leads_with_activity,
    sum(case when status = 'Won' then 1 else 0 end) as won_leads,
    cast(
        sum(case when status = 'Won' then 1 else 0 end) * 100.0
        / count(*)
        as decimal(5,2)
    ) as won_rate
from FollowUpBands
group by follow_up_speed
order by
    min(days_to_first_activity);
----- Validate 31+ Day Follow-Up Group by Lead Status
select
    fl.status,
    count (*) as lead_count,
    sum (case when fl.status = 'Won' then 1 else 0 end) as won_leads
from FactLeads_Cleaned fl
inner join (
    select
        lead_id,
        min (activity_date) as first_activity_date
    from FactCRMActivities
    group by lead_id
) fa
    on fl.lead_id = fa.lead_id
where fl.duplicate_flag = 'Keep'
  and datediff (day, fl.lead_date, fa.first_activity_date) >= 31
group by fl.status
order by lead_count desc;

-----5. H3: Rep performance is multi-dimensional — sales results alone may not fully explain rep performance.--------

-- Build Sales Rep Performance Baseline
select
       sr.rep_id,
       sr.rep_name,
       count(distinct fl.lead_id) as leads_handles,
       count(distinct case when fl.status = 'Won' then fl.lead_id end) as won_leads,
       cast(count (distinct case when fl.status = 'Won' then fl.lead_id end) * 100.0
               / nullif(count(distinct fl.lead_id), 0) as decimal(5,2)) as won_rate,
       count(distinct fs.sale_id) as sales_orders,
       sum(fs.amount_paid_ngn) as total_amount_paid,
       count(distinct fa.activity_id) as crm_activities
from DimSalesRep sr
left join FactLeads_Cleaned fl
     on sr.rep_id = fl.assigned_rep_id
     and fl.duplicate_flag = 'Keep'
left join FactSales fs
      on fl.lead_id = fs.lead_id
left join FactCRMActivities fa
      on fl.lead_id = fa.lead_id
group by sr.rep_id,
         sr.rep_name
order by total_amount_paid; 

----- Compare Sales Rep Performance Against Targets----------------------------

-- Compare Sales Rep Performance Against Monthly Targets
with MonthlySales as (
    select
        rep_id,
        year(sale_date) as sale_year,
        month(sale_date) as sale_month,
        count (*) as actual_deals,
        sum (amount_paid_ngn) as actual_amount_paid
     from FactSales
     group by
        rep_id,
        year (sale_date),
        month (sale_date)
)
  select
    sr.rep_id,
    sr.rep_name,
    sum(ft.target_revenue_ngn) as target_revenue,
    sum(ft.target_deals) as target_deals,
    sum(coalesce(ms.actual_deals, 0)) as actual_deals,
    sum(coalesce(ms.actual_amount_paid, 0)) as actual_amount_paid,
    cast(
        sum(coalesce(ms.actual_amount_paid, 0)) * 100.0
        / nullif(sum(ft.target_revenue_ngn), 0)
        as decimal(5,2)
    ) as revenue_target_achievement_pct,
    cast(
        sum(coalesce(ms.actual_deals, 0)) * 100.0
        / nullif(sum(ft.target_deals), 0)
        as decimal (5,2)
    ) as deal_target_achievement_pct
from FactTargets ft
inner join DimSalesRep sr
    on ft.rep_id = sr.rep_id
left join MonthlySales ms
    on ft.rep_id = ms.rep_id
    and left (ft.year_month, 4) = cast (ms.sale_year as varchar (4))
    and right (ft.year_month, 2) = right ('0' + cast (ms.sale_month as varchar (2)), 2)
group by
    sr.rep_id,
    sr.rep_name
order by
    revenue_target_achievement_pct desc;
---   
select distinct 
    year_month
from FactTargets
order by year_month;

-- Compare Rep Conversion With Target Achievement
with RepConversion as (
    select 
        rep_id,
        count (distinct lead_id) as leads_handled,
        count (distinct case
           when status = 'Won' then lead_id
        end) as won_leads,
        cast (
            count(distinct case
                when status = 'Won' then lead_id
            end) * 100.0
            / nullif(count(distinct lead_id), 0)
            as decimal (5,2)
        ) as won_rate
    from FactLeads_Cleaned
    where duplicate_flag = 'Keep'
    group by rep_id
),
MonthlySales as (
    select
        rep_id,
        YEAR(sale_date) as  sale_year,
        month (sale_date) as sale_month,
        count (*) as actual_deals,
        sum(amount_paid_ngn) as actual_amount_paid
    from FactSales
    group by
        rep_id,
        year(sale_date),
        month(sale_date)
),
TargetAchievement as (
    select
        ft.rep_id,
        sum(ft.target_revenue_ngn) as target_revenue,
        sum(ft.target_deals) as target_deals,
        sum(coalesce(ms.actual_deals, 0)) as actual_deals,
        sum(coalesce(ms.actual_amount_paid, 0)) as actual_amount_paid
    from FactTargets ft
    left join MonthlySales ms
        on ft.rep_id = ms.rep_id
        and left (ft.year_month, 4) = cast(ms.sale_year as varchar (4))
        and right (ft.year_month, 2) =
            right('0' + cast(ms.sale_month as varchar (2)), 2)
    group by ft.rep_id
)
select
    sr.rep_id,
    sr.rep_name,
    rc.leads_handled,
    rc.won_leads,
    rc.won_rate,
    ta.actual_deals,
    ta.actual_amount_paid,
    cast(
        ta.actual_amount_paid * 100.0
        / nullif (ta.target_revenue, 0)
        as decimal (5,2)
    ) as revenue_target_achievement_pct,
    cast(
        ta.actual_deals * 100.0
        / nullif (ta.target_deals, 0)
        as decimal (5,2)
    ) as deal_target_achievement_pct
from  DimSalesRep sr
left join RepConversion rc
    on sr.rep_id = rc.rep_id
left join TargetAchievement ta
    on sr.rep_id = ta.rep_id
order by revenue_target_achievement_pct desc;

-----6. H4: Lower-volume channels may generate disproportionately strong commercial outcomes.------------------------------

-- Compare Commercial Value by Lead Source
with LeadSummary as(
                      select
                         source_clean,
                         count(*) as lead_count
                     from FactLeads_Cleaned
                     where duplicate_flag ='Keep'
                     group by source_clean
),
SalesSummary as (
                  select
                        fl.source_clean,
                        count(fs.sale_id) as sales_orders,
                        sum(fs.amount_paid_ngn) as total_amount_paid
                  from FactSales fs
                  inner join FactLeads_Cleaned fl
                        on fs.lead_id = fl.lead_id
                  where fl.duplicate_flag = 'Keep'
                  group by fl.source_clean
)
select
      ls.source_clean,
      ls.lead_count,
      coalesce(ss.sales_orders, 0) as sales_orders,
      coalesce(ss.total_amount_paid, 0) as total_amount_paid,
      cast(coalesce(ss.total_amount_paid, 0) * 1.0 
           / nullif(ls.lead_count, 0) as decimal(12,2)) as amount_paid_per_lead
from LeadSummary ls
left join SalesSummary ss
     on ls.source_clean = ss.source_clean
order by amount_paid_per_lead  desc;

-----7. H5: Analyze Monthly Sales Performance ------------------------------                      
select
      year(sale_date) as sale_year,
      month(sale_date) as sale_month,
      count(*) as sales_orders,
      sum(amount_paid_ngn) as total_amount_paid
from FactSales
group by year(sale_date),
         month(sale_date)
order by sale_year,
         sale_month;

-- Compare Monthly Sales Across Years
select
      month(sale_date) as sale_month,
      sum(case when year(sale_date) = 2024 then 1 else 0 end) as orders_2024,
      sum(case when year(sale_date) = 2025 then 1 else 0 end) as orders_2025,
      sum(case when year(sale_date) = 2024 then amount_paid_ngn else 0 end) as amount_paid_2024,
      sum(case when year(sale_date) = 2025 then amount_paid_ngn else 0 end) as amount_paid_2025
from FactSales
group by month(sale_date)
order by sale_month;

----- Analyze Product Performance
select
     dp.product_id,
     dp.product_name,
     count(fs.sale_id) as sales_orders,
     count(distinct fs.customer_id) as unique_customers,
     sum(fs.amount_paid_ngn) as total_amount_paid,
     avg(fs.amount_paid_ngn) as average_amount_paid
from FactSales fs
inner join DimProduct dp
      on fs.product_id = dp.product_id
group by dp.product_id,
         dp.product_name
order by total_amount_paid desc;

----- Analyze Customer Purchase Frequency
select
     purchase_frequency,
     count(*) as customer_count
from (
       select
             customer_id,
             count(distinct sale_id) as purchase_count,
             case when count(distinct sale_id) = 1 then 'One-time'
                        else 'Repeat'
                   end as purchase_frequency
                   from FactSales
                   group by customer_id
        )    CustomerPurchase
group by purchase_frequency
order by customer_count desc;

----- Build Customer Purchase Profile
select
      fs.customer_id,
      count(distinct fs.sale_id) as purchase_count,
      sum(fs.amount_paid_ngn) as total_amount_paid,
      avg(fs.amount_paid_ngn) as average_order_value,
      count(distinct fs.product_id) as products_purchased,
      min(fs.sale_date) as first_purchase_date,
      max(fs.sale_date) as last_purchase_date
from FactSales fs
group by fs.customer_id
order by total_amount_paid desc;

-- Summarize Customer Purchase Frequency
with CustomerProfile as
(
  select
        customer_id,
        count (distinct sale_id) as purchase_count,
        sum (amount_paid_ngn) as total_amount_paid
    from FactSales
    group by customer_id
)
select
    purchase_count,
    count(*) as customer_count,
    sum(total_amount_paid) as total_amount_paid
from CustomerProfile
group by purchase_count
order by purchase_count;

-- Summarize Customer Value Distribution
with CustomerProfile as
(
    select
        customer_id,
        count (distinct sale_id) as purchase_count,
        sum(amount_paid_ngn) as total_amount_paid
    from FactSales
    group by customer_id
)
select
    min(total_amount_paid) as minimum_customer_value,
    avg (total_amount_paid) as average_customer_value,
    max(total_amount_paid) as maximum_customer_value,
    count (*) as total_customers
from CustomerProfile;

-- Analyze Customer Value Quartiles
with CustomerProfile as
(
    select
        customer_id,
        sum (amount_paid_ngn) AS total_amount_paid
    from FactSales
    group by customer_id
)
select distinct
    PERCENTILE_CONT(0.25)
        Wwithin group (order by total_amount_paid)
        over () as p25_customer_value,
    PERCENTILE_CONT(0.50)
        within group (order by total_amount_paid)
        over () as median_customer_value,
    PERCENTILE_CONT(0.75)
        within group (order by total_amount_paid)
        over () as p75_customer_value
from CustomerProfile;

-- Segment Customers by Purchase Frequency and Value
with CustomerProfile as
(
    select
        customer_id,
        count (distinct sale_id) as purchase_count,
        sum (amount_paid_ngn) as total_amount_paid
    from FactSales
    group by customer_id
),
CustomerValue as
(
    select
        *,
        PERCENTILE_CONT(0.75)
           within group (order by total_amount_paid)
            over () as p75_customer_value
    from CustomerProfile
),
CustomerSegments as
(
   select
        customer_id,
        purchase_count,
        total_amount_paid,
     case
            when  purchase_count > 1
                 and total_amount_paid >= p75_customer_value
                then 'Repeat - High Value'
            when purchase_count > 1
                then 'Repeat - Standard Value'
            when total_amount_paid >= p75_customer_value
                then 'One-time - High Value'
            else 'One-time - Standard Value'
        end as customer_segment
    from CustomerValue
)
select
    customer_segment,
    count(*) as customer_count,
    sum (total_amount_paid) as total_amount_paid,
    avg (total_amount_paid) as average_customer_value
from CustomerSegments
group by customer_segment
order by total_amount_paid desc;

exec sp_helptext 'FactLeads_cleaned';

select
    case
        when phone is null
         and email is null 
         and product_interest is null
            then  'All three missing'
        when phone is null
         and email is null 
            then 'Phone and email missing'
        when phone is null 
         and product_interest is null
           then 'Phone and product interest missing'
        when email is null 
         and product_interest is null
            then 'Email and product interest missing'
        when phone is null
            then 'Phone missing'
        when email is null 
            then 'Email missing'
        else 'Product interest missing'
    end as missing_field_pattern,
    count (*) as record_count
from FactLeads
where phone is null
   or email is null
   or product_interest is null
group by
    case
        when phone is null
         and email is null
         and product_interest is null
            then 'All three missing'
       when phone is null
         and email is null
            then 'Phone and email missing'
       when phone is null
         and product_interest is null 
            then 'Phone and product interest missing'
        when email is null
         and product_interest is null
            then 'Email and product interest missing'
        when phone is null
            then 'Phone missing'
        when email is null
            then 'Email missing'
        else 'Product interest missing'
    end
order by record_count desc;

----- Analytical population -------------------------------------------------
select
    count(*) as total_leads,
    sum(case when duplicate_flag = 'Keep' then 1 else 0 end) as keep_leads,
    sum(case when duplicate_flag = 'Duplicate' then 1 else 0 end) as duplicate_leads,
    sum(case when duplicate_flag = 'Not Checked' then 1 else 0 end) as unchecked_leads,
    sum(case when duplicate_flag = 'Keep'
              and sales_ready_date is not null
             then 1 else 0 end) AS keep_sales_ready_leads,
    sum(case when duplicate_flag = 'Keep'
              and status = 'Won'
             then 1 else 0 end) AS keep_won_leads
from FactLeads_cleaned;

----- Current Status Distribution of Leads
select
    status,
    duplicate_flag,
    count (*) as lead_count
from FactLeads_cleaned
where duplicate_flag IN ('Keep', 'Not Checked')
group by
    status,
    duplicate_flag
order by
    status,
    duplicate_flag;

----- Conversion Rate Analysis for Analytical Leads
select
    count (*) as analytical_leads,
    sum(case when sales_ready_date is not null 1
        else 0 end) as sales_ready_leads,
    sum(case when status = 'Won' then 1 
    else 0 end) as won_leads,
    cast( 100.0 * sum(
            case when status = 'Won' then 1 else 0 end
        ) / NULLIF(COUNT(*), 0)
        as decimal (5,2)
    ) as won_lead_rate_pct
from FactLeads_cleaned
where duplicate_flag IN ('Keep', 'Not Checked');

