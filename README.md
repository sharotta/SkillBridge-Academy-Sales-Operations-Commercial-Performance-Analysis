# SkillBridge Academy: Sales Operations & Commercial Performance Analysis
A business performance analysis exploring lead conversion, sales operations, customer purchasing behaviour, and commercial trends to identify performance gaps and opportunities for growth.

## Business Context

SkillBridge Academy is a professional training provider offering programmes designed to help individuals develop practical and career-relevant skills. Its commercial operations involve attracting prospective learners, managing enquiries through a sales process, assigning leads to sales representatives, and converting interested prospects into paying customers.

As the business manages multiple training programmes and acquisition sources, understanding how these activities contribute to sales performance is important for making informed commercial decisions. Management needs visibility into lead progression, sales execution, customer purchasing behaviour, and the revenue generated across its offerings.

This creates a need to evaluate the sales process as a connected system rather than viewing lead generation, sales activity, and commercial results in isolation.

## Business Problem

Generating leads is only one part of achieving strong sales performance. The business must also manage enquiries effectively, follow up with prospective customers, and convert opportunities into completed purchases.

When lead progression, sales activities, and commercial outcomes are examined separately, it can be difficult to identify where potential opportunities are being lost or which operational gaps deserve management's attention.

The challenge is to determine how effectively the sales process translates lead generation into commercial results, where performance differs across acquisition sources and sales representatives, and which areas warrant further investigation or improvement.

## Project Context

This project analyses sales and CRM data covering January 2024 to December 2025 to evaluate sales performance across the lead lifecycle, sales operations, sales representatives, training programmes, and customer purchasing behaviour.

The analysis combines lead records, CRM activities, sales transactions, customer information, and sales targets to examine how operational performance relates to commercial outcomes.

SQL Server was used to profile and prepare the data, validate data quality, and investigate the business questions. Power BI was used to bring the findings together in an interactive dashboard, allowing performance to be explored by year, sales representative, and lead source.

The scope is to identify meaningful performance patterns, highlight operational gaps, and provide evidence-based recommendations for management consideration.

## Business Questions

The analysis was guided by the following business questions:

1. **Lead Conversion:** How effectively do leads progress through the sales process, and where are the main conversion gaps?
2. **Lead Source Performance:** Which acquisition sources generate leads that convert into sales, and how does their contribution to recorded sales differ?
3. **Sales Operations:** How do lead assignment and CRM follow-up activity vary, and what operational gaps require attention?
4. **Sales Representative Performance:** How does performance vary across sales representatives, and how does actual performance compare with assigned targets?
5. **Programme Performance:** Which training programmes contribute most to recorded sales, and how does performance vary across programmes?
6. **Customer Purchasing Behaviour:** How do one-time and repeat customers differ in their contribution to recorded payments?
7. **Sales Trends:** How do monthly sales payments and order volumes change over time?

These questions structure the investigation around the relationship between sales operations and commercial outcomes, helping management identify performance gaps and areas that warrant further investigation.

## Key Findings

The analysis revealed several patterns across lead conversion, sales operations, and customer purchasing behaviour:

- **Lead conversion:** Of the 13,562 analytical leads, 4,510 (33.25%) reached sales-ready status, while 2,175 (16.04%) were recorded as Won. This highlights the gap between lead acquisition and successful sales outcomes.

- **Lead assignment:** 696 leads (5.13%) had no assigned sales representative, indicating an operational gap in lead ownership.

- **CRM documentation:** 814 Lost leads had no recorded lost reason, limiting visibility into why these opportunities were unsuccessful.

- **Customer purchasing behaviour:** Of 2,242 purchasing customers, 1,992 (88.85%) made one recorded purchase, while 250 (11.15%) made repeat purchases.

- **Customer sales contribution:** Repeat customers contributed 20.1% of recorded payments despite representing only 11.15% of purchasing customers. One-time customers accounted for the remaining 79.9%.

The analysis also examined sales contribution across representatives and training programmes, performance against assigned targets, and monthly changes in sales payments and order volumes. These findings provide a basis for identifying areas that warrant management attention and further investigation.

## Data Overview

The analysis uses a relational dataset consisting of **10 tables**, organised into dimension and fact tables to support the investigation of sales operations and commercial performance.

The dataset covers January 2024 to December 2025 and contains records relating to leads, customers, sales transactions, CRM activities, sales representatives, training programmes, acquisition sources, and performance targets.

### Dataset Structure

The database contains five dimension tables and five fact tables.

| Table | Records | Description |
|---|---:|---|
| DimDate | 731 | Calendar reference supporting time-based analysis |
| DimSalesRep | 14 | Sales representative details |
| DimProduct | 7 | Training programme information |
| DimLeadSource | 7 | Lead acquisition source categories |
| DimLostReason | 7 | Reference categories for lost lead reasons |
| FactLeads | 14,040 | Lead records and their progression through the sales process |
| DimCustomer | 5,451 | Customer profile information |
| FactSales | 2,492 | Sales transaction and payment records |
| FactCRMActivities | 34,160 | Recorded interactions and follow-up activities |
| FactTargets | 288 | Sales performance targets by representative and reporting period |

The dimension tables provide descriptive information for filtering and grouping analysis, while the fact tables contain the operational and transactional records used to calculate performance metrics.

Together, these tables provide the foundation for analysing lead conversion, sales execution, representative performance, programme contribution, customer purchasing behaviour, and sales trends.

## Analytical Approach

The analysis followed a structured, business-focused approach, moving from understanding the dataset to investigating performance patterns and identifying areas requiring management attention.

SQL analysis was organised around the key business questions, with each area examining a different aspect of the sales operation.

- **Lead Conversion Analysis:** Examined lead status distribution, sales-ready progression, and successful sales outcomes to understand how leads moved through the sales process.

- **Lead Source Analysis:** Compared acquisition sources based on lead volume, sales-ready progression, conversion outcomes, and contribution to recorded sales.

- **Sales Operations Analysis:** Investigated lead assignment, CRM activity patterns, follow-up timelines, and missing lost reasons to identify potential gaps in sales execution and record management.

- **Sales Representative Analysis:** Evaluated sales contribution and compared actual performance against assigned revenue and deal targets.

- **Programme Performance Analysis:** Examined sales contribution and order volumes across training programmes to understand differences in commercial performance.

- **Customer Performance Analysis:** Evaluated one-time and repeat purchasing behaviour, customer contribution to recorded payments, and monthly sales and order trends.

The results were consolidated into a Power BI dashboard to support interactive exploration across reporting years, sales representatives, and lead sources.

The analysis focused on identifying performance differences, understanding the factors associated with sales outcomes, and highlighting areas where management could take a closer look.

## Data Preparation & Modelling

Before conducting the analysis, the dataset was profiled, assessed for data-quality issues, and prepared for consistent reporting.

### Data Profiling & Quality Assessment

All 10 tables were examined to understand their structure, record volumes, data types, and content. Checks covered missing values, duplicate records, inconsistent categorical values, date ranges, and potential anomalies.

The profiling identified several issues requiring attention, including incomplete lead contact information, unassigned leads, inconsistent lead-source and location values, missing lost reasons, and suspected duplicate lead records.

Partial payments were also identified in the sales data. These were retained because they represent payment conditions associated with completed orders rather than automatically indicating invalid transactions.

### Data Cleaning & Standardisation

Lead-source and location variations were standardised using dedicated mapping tables, allowing raw values to be retained while providing consistent categories for analysis.

Suspected duplicate leads were identified using a combination of phone number, email address, and product interest. Matching records were flagged rather than physically deleted, preserving the original CRM records for review.

Records that lacked the information required for duplicate checking were retained under a separate `Not Checked` classification. The analytical population therefore included records marked `Keep` and `Not Checked`, while excluding those flagged as `Duplicate`.

Missing values were handled according to their business meaning. For example, unassigned leads and missing lost reasons were retained because they represent operational information that may be relevant to management.

### Data Modelling

The dataset was organised around dimension and fact tables to support analysis across dates, sales representatives, training programmes, lead sources, customers, sales transactions, CRM activities, and targets.

This structure provided a consistent basis for filtering, aggregating, and comparing performance across the different areas of the business.

## SQL Analysis & Query Development

SQL Server was used to prepare the analytical dataset, combine information across related tables, and calculate the metrics required to evaluate sales and operational performance.

The analysis involved:

- Using joins to bring together lead, customer, sales, representative, and CRM activity records.
- Applying aggregations and conditional calculations to measure lead volumes, conversion rates, sales contributions, and target achievement.
- Using Common Table Expressions (CTEs) to organise multi-step analytical queries.
- Applying window functions, including `ROW_NUMBER()`, to identify and flag suspected duplicate lead records.
- Creating views to make standardised and cleaned data available for downstream analysis.

The queries were organised around the business questions, with the resulting metrics and findings used to support the Power BI dashboard.

### Power BI Dashboard
### Executive Overview
The Executive Overview brings together key performance indicators and four visuals to assess lead conversion, lead outcomes, and sales performance across January 2024–December 2025.

<img width="971" height="547" alt="Executive Overview" src="https://github.com/user-attachments/assets/d0e3e501-b163-475e-ad1e-d483b47e12db" />

**Key Performance Indicators**

| KPI | Result |
|---|---:|
| Analytical Leads | 13,562 |
| Sales-Ready Leads | 4,510 |
| Won Leads | 2,175 |
| Conversion Rate | 16.04% |
| Sales Orders | 2,492 |
| Total Sales Payments | ₦789M |

**Visual 1: Conversion Rate by Acquisition Source**


Compares the proportion of leads converted into Won outcomes across acquisition sources.

- Corporate Outreach recorded the highest conversion rate (25.62%), followed by Referral (24.45%) and Walk-in (20.69%).
- Facebook/Instagram Ads recorded the lowest rate (10.03%).

*Business implication:* Higher lead volume does not necessarily translate into stronger conversion. Management should investigate the practices behind higher-converting sources and examine the lower conversion performance of Facebook/Instagram Ads.

**Visual 2: Lead Outcomes Across the Analytical Population**

Shows how the 13,562 analytical leads are distributed across their recorded statuses.

- Contacted: 3,670
- Lost: 3,389
- New: 3,269
- Won: 2,175
- Nurture: 1,059

*Business implication:* The volume of Lost leads highlights the importance of understanding unsuccessful opportunities, while New and Nurture leads require appropriate monitoring and follow-up.

**Visual 3: Monthly Sales Performance Over Time**

Tracks monthly recorded sales payments across the two-year period.

- January recorded the highest monthly payments in both years: ₦55.3M in 2024 and ₦50.45M in 2025.
- December recorded the lowest payments in both years.
- Total recorded payments declined by approximately 2.4% in 2025 compared with 2024.

*Business implication:* The recurring monthly pattern and year-on-year decline warrant further investigation into demand, order volumes, and sales execution.

**Visual 4: Sales Contribution by Acquisition Source**

Compares recorded sales payments across acquisition sources.

| Acquisition Source | Sales Contribution |
|---|---:|
| Google Ads | ₦161.65M |
| Website | ₦158.94M |
| Facebook/Instagram Ads | ₦137.18M |
| Referral | ₦117.54M |
| Organic Social Media | ₦97.18M |
| Walk-in | ₦64.84M |
| Corporate Outreach | ₦51.31M |

*Business implication:* Google Ads and Website contributed the highest recorded sales payments, while Corporate Outreach had the highest conversion rate but the lowest sales contribution. Acquisition decisions should therefore consider both conversion efficiency and commercial contribution.

**Overall Management Focus:** Improve lead progression and follow-up execution, investigate differences in acquisition-source performance, and use both conversion rates and sales contribution when evaluating acquisition effectiveness.
