# bike_share_2.0

Beginning of June 2023 I finalized the Google Data Analyst Professional Certificate and completed a case study with data from fictional bike share company as the capstone project to earn the certificate.

In the weeks after I uploaded my case study to GitHub I finished a course on more advance SQL topics and passed the exam "Basic Proficiency in KNIME Analytics Platform" (ETL tool). With this new knowledge I decided to revisit the Google case study and do it again from scratch.

In KNIME created a data pipeline to combine the 12 CSV files provided and performed data cleaning and data manipulation. The data manupulation in KNIME allowed me to use the geographical coordinates in the data source to calculate the distance between the pick up and drop off of shared-bikes in Chicago. These geographical coordinates were not used at all in my first trial and now became one additional measure that we could use to generate data-informed decisions.

Also very interesting, in the first case study I loaded all 12 files into MySQL directly and the result was the data combined in one-big-table with 1,2 GB.
Using KNIME I could split the combined CSV files into three tables and really take advantage of the benefits of working with relatational databases. The three tables combined add up to 454 mb, less than 50% of the one-big-table. This I consider a great improvement :)

In this new repository you find the SQL code writen in MySQL, a .pdf file where I place the outcome of my queries and another .pdf file where I explain the steps taken in KNIME to create the tables used in this analysis.

I learned a lot in the past weeks and I'm happy I can showcase my new skills in this bike-share_2.0 which you find here: https://github.com/pcargolo/bike_share_2.0  
The first case study can be found in this other link and it's very satisfying to me to see the improvement: https://github.com/pcargolo/bike-share

I'm looking forward to what I can further unlock with my next steps in my Data Journey.  
If you have any feedback please get in touch with me and I'll be happy to connect: https://www.linkedin.com/in/pauloargolo/


