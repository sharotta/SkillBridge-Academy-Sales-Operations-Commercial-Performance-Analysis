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

## 6. Data Overview

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
