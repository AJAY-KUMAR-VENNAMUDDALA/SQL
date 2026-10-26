-- ============================================================
-- SALES AGGREGATION REPORT USING DATE VARIABLES
-- ORACLE SQL + PL/SQL
-- ============================================================

   SET SERVEROUTPUT ON;


-- ============================================================
-- 1. CREATE SALES TABLE
-- ============================================================

create table retail_sales (
   sale_id      number primary key,
   product_name varchar2(50),
   category     varchar2(50),
   quantity     number,
   amount       number(10,2),
   sale_date    date
);


-- ============================================================
-- 2. INSERT SAMPLE DATA
-- ============================================================

insert into retail_sales values
   ( 1,
     'Laptop',
     'Electronics',
     2,
     100000,
     to_date('01-10-2026','DD-MM-YYYY') );

insert into retail_sales values
   ( 2,
     'Mobile',
     'Electronics',
     3,
     75000,
     to_date('02-10-2026','DD-MM-YYYY') );

insert into retail_sales values
   ( 3,
     'Chair',
     'Furniture',
     4,
     32000,
     to_date('03-10-2026','DD-MM-YYYY') );

insert into retail_sales values
   ( 4,
     'Laptop',
     'Electronics',
     1,
     50000,
     to_date('05-10-2026','DD-MM-YYYY') );

insert into retail_sales values
   ( 5,
     'Table',
     'Furniture',
     2,
     24000,
     to_date('07-10-2026','DD-MM-YYYY') );

insert into retail_sales values
   ( 6,
     'Mobile',
     'Electronics',
     2,
     50000,
     to_date('10-10-2026','DD-MM-YYYY') );

insert into retail_sales values
   ( 7,
     'Headphones',
     'Electronics',
     5,
     10000,
     to_date('12-10-2026','DD-MM-YYYY') );

insert into retail_sales values
   ( 8,
     'Chair',
     'Furniture',
     3,
     24000,
     to_date('15-10-2026','DD-MM-YYYY') );

insert into retail_sales values
   ( 9,
     'Laptop',
     'Electronics',
     2,
     110000,
     to_date('18-10-2026','DD-MM-YYYY') );

insert into retail_sales values
   ( 10,
     'Table',
     'Furniture',
     1,
     12000,
     to_date('20-10-2026','DD-MM-YYYY') );

commit;


-- Check data

select *
  from retail_sales;


-- ============================================================
-- PROCEDURE 1
-- SALES REPORT BETWEEN TWO DATES
-- ============================================================

create or replace procedure sales_report (
   p_start_date in date,
   p_end_date   in date
) as
   v_total_sales    number;
   v_total_quantity number;
   v_total_orders   number;
begin
   select sum(amount),
          sum(quantity),
          count(*)
     into
      v_total_sales,
      v_total_quantity,
      v_total_orders
     from retail_sales
    where sale_date between p_start_date and p_end_date;


   dbms_output.put_line('Start Date     : ' || to_char(
      p_start_date,
      'DD-MM-YYYY'
   ));
   dbms_output.put_line('End Date       : ' || to_char(
      p_end_date,
      'DD-MM-YYYY'
   ));
   dbms_output.put_line('Total Sales    : ' || v_total_sales);
   dbms_output.put_line('Total Quantity : ' || v_total_quantity);
   dbms_output.put_line('Total Orders   : ' || v_total_orders);
end;
/


-- ============================================================
-- CALL PROCEDURE 1
-- ============================================================

begin
   sales_report(
      to_date('01-10-2026',
                'DD-MM-YYYY'),
      to_date('10-10-2026',
                'DD-MM-YYYY')
   );
end;
/


-- Example output:
--
-- Start Date     : 01-10-2026
-- End Date       : 10-10-2026
-- Total Sales    : 331000
-- Total Quantity : 14
-- Total Orders   : 6


-- ============================================================
-- PROCEDURE 2
-- COMPLETE SALES AGGREGATION REPORT
-- SUM + COUNT + AVG + MIN + MAX
-- ============================================================

create or replace procedure sales_summary (
   p_start_date in date,
   p_end_date   in date
) as
   v_total_sales number;
   v_avg_sales   number;
   v_min_sales   number;
   v_max_sales   number;
   v_order_count number;
begin
   select sum(amount),
          avg(amount),
          min(amount),
          max(amount),
          count(*)
     into
      v_total_sales,
      v_avg_sales,
      v_min_sales,
      v_max_sales,
      v_order_count
     from retail_sales
    where sale_date between p_start_date and p_end_date;


   dbms_output.put_line('===== SALES REPORT =====');
   dbms_output.put_line('From : ' || to_char(
      p_start_date,
      'DD-MM-YYYY'
   ));
   dbms_output.put_line('To   : ' || to_char(
      p_end_date,
      'DD-MM-YYYY'
   ));
   dbms_output.put_line('Total Sales   : ' || v_total_sales);
   dbms_output.put_line('Average Sale  : ' || round(
      v_avg_sales,
      2
   ));
   dbms_output.put_line('Minimum Sale  : ' || v_min_sales);
   dbms_output.put_line('Maximum Sale  : ' || v_max_sales);
   dbms_output.put_line('Total Orders  : ' || v_order_count);
end;
/


-- ============================================================
-- CALL PROCEDURE 2
-- ============================================================

begin
   sales_summary(
      to_date('01-10-2026',
                 'DD-MM-YYYY'),
      to_date('20-10-2026',
                 'DD-MM-YYYY')
   );
end;
/


-- ============================================================
-- PROCEDURE 3
-- SALES REPORT FOR ONE PARTICULAR DATE
-- ============================================================

create or replace procedure daily_sales_report (
   p_date in date
) as
   v_total_sales    number;
   v_total_quantity number;
   v_orders         number;
begin
   select sum(amount),
          sum(quantity),
          count(*)
     into
      v_total_sales,
      v_total_quantity,
      v_orders
     from retail_sales
    where sale_date = p_date;


   dbms_output.put_line('Date           : ' || to_char(
      p_date,
      'DD-MM-YYYY'
   ));
   dbms_output.put_line('Total Sales    : ' || v_total_sales);
   dbms_output.put_line('Quantity Sold  : ' || v_total_quantity);
   dbms_output.put_line('Orders         : ' || v_orders);
end;
/


-- ============================================================
-- CALL DAILY REPORT
-- ============================================================

begin
   daily_sales_report(to_date('05-10-2026',
                      'DD-MM-YYYY'));
end;
/


-- ============================================================
-- PROCEDURE 4
-- CATEGORY SALES REPORT BETWEEN TWO DATES
-- ============================================================

create or replace procedure category_sales_report (
   p_category   in varchar2,
   p_start_date in date,
   p_end_date   in date
) as
   v_total_sales    number;
   v_total_quantity number;
   v_orders         number;
begin
   select sum(amount),
          sum(quantity),
          count(*)
     into
      v_total_sales,
      v_total_quantity,
      v_orders
     from retail_sales
    where category = p_category
      and sale_date between p_start_date and p_end_date;


   dbms_output.put_line('Category       : ' || p_category);
   dbms_output.put_line('Start Date     : ' || to_char(
      p_start_date,
      'DD-MM-YYYY'
   ));
   dbms_output.put_line('End Date       : ' || to_char(
      p_end_date,
      'DD-MM-YYYY'
   ));
   dbms_output.put_line('Total Sales    : ' || v_total_sales);
   dbms_output.put_line('Quantity Sold  : ' || v_total_quantity);
   dbms_output.put_line('Orders         : ' || v_orders);
end;
/


-- ============================================================
-- CALL CATEGORY REPORT
-- Electronics sales from Oct 1 to Oct 15
-- ============================================================

begin
   category_sales_report(
      'Electronics',
      to_date('01-10-2026',
                         'DD-MM-YYYY'),
      to_date('15-10-2026',
                         'DD-MM-YYYY')
   );
end;
/


-- ============================================================
-- IMPORTANT CONCEPT
-- ============================================================

-- DATE VARIABLES
--
-- p_start_date IN DATE
-- p_end_date   IN DATE
--
-- These values are received when we call the procedure.


-- ============================================================
-- AGGREGATION FUNCTIONS USED
-- ============================================================

-- SUM(amount)
--     Total revenue

-- SUM(quantity)
--     Total products sold

-- COUNT(*)
--     Number of sales/orders

-- AVG(amount)
--     Average sales amount

-- MIN(amount)
--     Smallest sale

-- MAX(amount)
--     Largest sale


-- ============================================================
-- BASIC BUSINESS FLOW
-- ============================================================

-- User provides:
--
-- 01-10-2026
--      |
--      | Start Date
--      |
--      V
-- SALES TABLE
--      |
--      | Filter
--      |
--      V
-- 10-10-2026
--      |
--      V
-- SUM(amount)
-- SUM(quantity)
-- COUNT(*)
-- AVG(amount)
-- MIN(amount)
-- MAX(amount)
--      |
--      V
-- SALES AGGREGATION REPORT