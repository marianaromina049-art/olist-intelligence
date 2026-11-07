-- Q1: Ingresos mensuales y crecimiento vs mes anterior (CTE + LAG)
WITH monthly AS (
  SELECT date_trunc('month', o.order_purchase_timestamp::timestamp) AS month,
         SUM(i.price) AS revenue,
         COUNT(DISTINCT o.order_id) AS orders
  FROM raw.orders o
  JOIN raw.order_items i USING (order_id)
  WHERE o.order_status = 'delivered'
  GROUP BY 1
)
SELECT month, 
       orders, 
       ROUND(revenue::numeric, 0) AS revenue,
       ROUND((revenue / LAG(revenue) OVER (ORDER BY month) - 1)::numeric * 100, 1) AS mom_pct
FROM monthly 
ORDER BY month;


-- Q2: Tasa de retraso en entregas por estado del cliente (JOIN + HAVING + CASE/CAST)
SELECT c.customer_state,
       COUNT(*) AS orders,
       ROUND(AVG((o.order_delivered_customer_date::timestamp
                  > o.order_estimated_delivery_date::timestamp)::int)::numeric * 100, 2) AS late_pct
FROM raw.orders o
JOIN raw.customers c USING (customer_id)
WHERE o.order_status = 'delivered' AND o.order_delivered_customer_date IS NOT NULL
GROUP BY 1
HAVING COUNT(*) >= 500
ORDER BY late_pct DESC;


-- Q3: Vista reutilizable - Tabla de hechos por pedido (CREATE VIEW)
CREATE SCHEMA IF NOT EXISTS mart;

CREATE OR REPLACE VIEW mart.order_facts AS
SELECT o.order_id, 
       o.customer_id, 
       o.order_status,
       o.order_purchase_timestamp::timestamp AS purchased_at,
       o.order_delivered_customer_date::timestamp AS delivered_at,
       o.order_estimated_delivery_date::timestamp AS estimated_at,
       SUM(i.price) AS items_value, 
       SUM(i.freight_value) AS freight_value, 
       COUNT(*) AS n_items
FROM raw.orders o 
JOIN raw.order_items i USING (order_id)
GROUP BY o.order_id, o.customer_id, o.order_status, o.order_purchase_timestamp, o.order_delivered_customer_date, o.order_estimated_delivery_date;


-- Q4: Top 10 categorías de productos con mayores ingresos totales (JOIN múltiple)
SELECT p.product_category_name,
       COUNT(DISTINCT i.order_id) AS total_orders,
       ROUND(SUM(i.price)::numeric, 2) AS total_revenue
FROM raw.order_items i
JOIN raw.products p USING (product_id)
JOIN raw.orders o USING (order_id)
WHERE o.order_status = 'delivered' AND p.product_category_name IS NOT NULL
GROUP BY p.product_category_name
ORDER BY total_revenue DESC
LIMIT 10;


-- Q5: Vendedores con peor tasa de retraso con al menos 30 pedidos (HAVING + AVG)
SELECT s.seller_id,
       COUNT(o.order_id) AS total_orders,
       ROUND(AVG((o.order_delivered_customer_date::timestamp 
                  > o.order_estimated_delivery_date::timestamp)::int)::numeric * 100, 2) AS late_rate_pct
FROM raw.orders o
JOIN raw.order_items i USING (order_id)
JOIN raw.sellers s USING (seller_id)
WHERE o.order_status = 'delivered' AND o.order_delivered_customer_date IS NOT NULL
GROUP BY s.seller_id
HAVING COUNT(o.order_id) >= 30
ORDER BY late_rate_pct DESC
LIMIT 15;


-- Q6: Ticket promedio de compra agrupado por método de pago (JOIN + AVG)
SELECT p.payment_type,
       COUNT(DISTINCT p.order_id) AS total_transactions,
       ROUND(AVG(p.payment_value)::numeric, 2) AS avg_ticket,
       ROUND(SUM(p.payment_value)::numeric, 2) AS total_amount
FROM raw.order_payments p
JOIN raw.orders o USING (order_id)
WHERE o.order_status = 'delivered'
GROUP BY p.payment_type
ORDER BY total_amount DESC;


-- Q7: Ranking de vendedores por ingresos dentro de cada estado (RANK + Window Function)
WITH seller_rev AS (
  SELECT s.seller_id,
         s.seller_state,
         SUM(i.price) AS revenue
  FROM raw.sellers s
  JOIN raw.order_items i USING (seller_id)
  JOIN raw.orders o USING (order_id)
  WHERE o.order_status = 'delivered'
  GROUP BY s.seller_id, s.seller_state
)
SELECT seller_id,
       seller_state,
       ROUND(revenue::numeric, 2) AS revenue,
       RANK() OVER (PARTITION BY seller_state ORDER BY revenue DESC) AS rank_in_state
FROM seller_rev
ORDER BY seller_state, rank_in_state;


-- Q8: Calificación promedio de reseñas por categoría de producto (JOIN múltiple)
SELECT p.product_category_name,
       COUNT(r.review_id) AS review_count,
       ROUND(AVG(r.review_score)::numeric, 2) AS avg_score
FROM raw.order_reviews r
JOIN raw.orders o USING (order_id)
JOIN raw.order_items i USING (order_id)
JOIN raw.products p USING (product_id)
WHERE p.product_category_name IS NOT NULL
GROUP BY p.product_category_name
HAVING COUNT(r.review_id) >= 100
ORDER BY avg_score DESC;


-- Q9: Porcentaje de clientes recurrentes vs de una sola compra (CTE + COUNT)
WITH customer_orders AS (
  SELECT customer_unique_id,
         COUNT(order_id) AS total_orders
  FROM raw.customers
  JOIN raw.orders USING (customer_id)
  WHERE order_status = 'delivered'
  GROUP BY customer_unique_id
)
SELECT ROUND(AVG((total_orders > 1)::int)::numeric * 100, 2) AS repeat_customer_pct,
       COUNT(*) FILTER (WHERE total_orders = 1) AS single_order_customers,
       COUNT(*) FILTER (WHERE total_orders > 1) AS repeat_customers
FROM customer_orders;


-- Q10: Tiempo promedio de entrega en días agrupado por mes (EXTRACT / DATE_PART)
SELECT date_trunc('month', order_purchase_timestamp::timestamp) AS month,
       ROUND(AVG(EXTRACT(DAY FROM (order_delivered_customer_date::timestamp - order_purchase_timestamp::timestamp)))::numeric, 1) AS avg_delivery_days
FROM raw.orders
WHERE order_status = 'delivered' AND order_delivered_customer_date IS NOT NULL
GROUP BY 1
ORDER BY month;


-- Q11: Relación entre costo de flete y precio del producto por categoría (FILTER / AVG)
SELECT p.product_category_name,
       ROUND(AVG(i.price)::numeric, 2) AS avg_price,
       ROUND(AVG(i.freight_value)::numeric, 2) AS avg_freight,
       ROUND((AVG(i.freight_value) / NULLIF(AVG(i.price), 0))::numeric * 100, 2) AS freight_ratio_pct
FROM raw.order_items i
JOIN raw.products p USING (product_id)
WHERE p.product_category_name IS NOT NULL
GROUP BY p.product_category_name
HAVING COUNT(*) >= 200
ORDER BY freight_ratio_pct DESC;


-- Q12: Clasificación y conteo del estado de pedidos (CASE WHEN)
SELECT CASE 
         WHEN order_status = 'delivered' THEN 'Entregado'
         WHEN order_status = 'shipped' THEN 'En tránsito'
         WHEN order_status = 'canceled' THEN 'Cancelado'
         ELSE 'Otros / En proceso'
       END AS status_group,
       COUNT(*) AS total_orders,
       ROUND((COUNT(*)::numeric / SUM(COUNT(*)) OVER ()) * 100, 2) AS pct
FROM raw.orders
GROUP BY status_group
ORDER BY total_orders DESC;


-- Q13: Día de la semana con mayor volumen de ventas (TO_CHAR / GROUP BY)
SELECT TO_CHAR(o.order_purchase_timestamp::timestamp, 'Day') AS day_of_week,
       COUNT(DISTINCT o.order_id) AS total_orders,
       ROUND(SUM(i.price)::numeric, 2) AS total_revenue
FROM raw.orders o
JOIN raw.order_items i USING (order_id)
WHERE o.order_status = 'delivered'
GROUP BY 1, EXTRACT(DOW FROM o.order_purchase_timestamp::timestamp)
ORDER BY EXTRACT(DOW FROM o.order_purchase_timestamp::timestamp);


-- Q14: Top 5 ciudades con mayor número de clientes registrados (COUNT + GROUP BY)
SELECT customer_city,
       customer_state,
       COUNT(DISTINCT customer_unique_id) AS total_unique_customers
FROM raw.customers
GROUP BY customer_city, customer_state
ORDER BY total_unique_customers DESC
LIMIT 5;


-- Q15: Primeras y últimas compras realizadas por cliente (ROW_NUMBER / Window Function)
WITH ranked_orders AS (
  SELECT c.customer_unique_id,
         o.order_id,
         o.order_purchase_timestamp::timestamp AS purchase_time,
         ROW_NUMBER() OVER (PARTITION BY c.customer_unique_id ORDER BY o.order_purchase_timestamp::timestamp ASC) AS rn_first,
         ROW_NUMBER() OVER (PARTITION BY c.customer_unique_id ORDER BY o.order_purchase_timestamp::timestamp DESC) AS rn_last
  FROM raw.customers c
  JOIN raw.orders o USING (customer_id)
)
SELECT customer_unique_id,
       MAX(purchase_time) FILTER (WHERE rn_first = 1) AS first_order_date,
       MAX(purchase_time) FILTER (WHERE rn_last = 1) AS latest_order_date,
       COUNT(*) AS total_orders
FROM ranked_orders
GROUP BY customer_unique_id
HAVING COUNT(*) > 1
LIMIT 10;