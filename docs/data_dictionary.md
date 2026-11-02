# Diccionario de Datos

## 1. olist_orders_dataset
- **Clave Primaria:** order_id
- **Claves Foráneas:** customer_id
- **Granularidad:** Una fila = Un pedido único realizado por un cliente.
- **Descripción de columnas:**
  - `order_id`: Identificador único para cada pedido realizado.
  - `customer_id`: Identificador único del cliente que realizó el pedido.
  - `order_status`: Estado actual o final del pedido (ej. delivered, invoiced).
  - `order_purchase_timestamp`: Fecha y hora exactas de la compra.
  - `order_approved_at`: Fecha y hora de aprobación del pago.
  - `order_delivered_carrier_date`: Fecha y hora de entrega al servicio de logística.
  - `order_delivered_customer_date`: Fecha y hora de entrega al cliente final.
  - `order_estimated_delivery_date`: Fecha estimada de entrega calculada al comprar.

## 2. olist_products_dataset
- **Clave Primaria:** product_id
- **Claves Foráneas:** Ninguna
- **Granularidad:** Una fila = Un producto único registrado en el catálogo.
- **Descripción de columnas:**
  - `product_id`: Identificador único para cada producto.
  - `product_category_name`: Nombre de la categoría del producto (en portugués).
  - `product_name_lenght`: Longitud de caracteres del nombre del producto.
  - `product_description_lenght`: Longitud de caracteres de la descripción.
  - `product_photos_qty`: Cantidad de fotos disponibles del producto.
  - `product_weight_g`: Peso del producto en gramos.
  - `product_length_cm`: Longitud física en centímetros.
  - `product_height_cm`: Altura física en centímetros.
  - `product_width_cm`: Ancho físico en centímetros.

## 3. olist_sellers_dataset
- **Clave Primaria:** seller_id
- **Claves Foráneas:** Ninguna
- **Granularidad:** Una fila = Un vendedor único registrado en la plataforma.
- **Descripción de columnas:**
  - `seller_id`: Identificador único para cada vendedor.
  - `seller_zip_code_prefix`: Prefijo del código postal del vendedor.
  - `seller_city`: Ciudad donde se ubica el vendedor.
  - `seller_state`: Estado o provincia del vendedor.

## 4. product_category_name_translation
- **Clave Primaria:** product_category_name
- **Claves Foráneas:** Ninguna
- **Granularidad:** Una fila = La traducción de una categoría de producto de portugués a inglés.
- **Descripción de columnas:**
  - `product_category_name`: Nombre de la categoría en portugués.
  - `product_category_name_english`: Nombre de la categoría traducido al inglés.

## 5. olist_geolocation_dataset
- **Clave Primaria:** Ninguna estricta (referencia: geolocation_zip_code_prefix)
- **Claves Foráneas:** Ninguna
- **Granularidad:** Una fila = Un registro de coordenadas geográficas (lat/lng) asociadas a un prefijo postal.
- **Descripción de columnas:**
  - `geolocation_zip_code_prefix`: Prefijo del código postal brasileño.
  - `geolocation_lat`: Latitud geográfica.
  - `geolocation_lng`: Longitud geográfica.
  - `geolocation_city`: Ciudad correspondiente.
  - `geolocation_state`: Estado correspondiente.

## 6. olist_order_items_dataset
- **Clave Primaria:** order_id + order_item_id
- **Claves Foráneas:** order_id, product_id, seller_id
- **Granularidad:** Una fila = Un producto o ítem específico dentro de un pedido.
- **Descripción de columnas:**
  - `order_id`: Identificador único del pedido.
  - `order_item_id`: Número secuencial del ítem dentro del pedido.
  - `product_id`: Identificador único del producto.
  - `seller_id`: Identificador único del vendedor.
  - `shipping_limit_date`: Fecha y hora límite para entregar el producto a logística.
  - `price`: Precio de venta del producto.
  - `freight_value`: Costo de envío (flete).

## 7. olist_order_payments_dataset
- **Clave Primaria:** order_id + payment_sequential
- **Claves Foráneas:** order_id
- **Granularidad:** Una fila = Una transacción o cuota de pago asociada a un pedido.
- **Descripción de columnas:**
  - `order_id`: Identificador único del pedido.
  - `payment_sequential`: Número secuencial del pago dentro del pedido.
  - `payment_type`: Método de pago utilizado.
  - `payment_installments`: Número de cuotas elegidas.
  - `payment_value`: Monto pagado en esta transacción.

## 8. olist_order_reviews_dataset
- **Clave Primaria:** review_id
- **Claves Foráneas:** order_id
- **Granularidad:** Una fila = Una reseña o calificación emitida por un cliente sobre un pedido.
- **Descripción de columnas:**
  - `review_id`: Identificador único de la reseña.
  - `order_id`: Identificador único del pedido reseñado.
  - `review_score`: Puntuación otorgada (1 a 5).
  - `review_comment_title`: Título del comentario.
  - `review_comment_message`: Mensaje o texto detallado de la reseña.
  - `review_creation_date`: Fecha de creación de la encuesta/reseña.
  - `review_answer_timestamp`: Fecha de respuesta a la reseña.

## 9. olist_customers_dataset
- **Clave Primaria:** customer_id
- **Claves Foráneas:** Ninguna
- **Granularidad:** Una fila = Un identificador de cliente asociado a una orden de compra específica.
- **Descripción de columnas:**
  - `customer_id`: Identificador del cliente asignado por cada pedido.
  - `customer_unique_id`: Identificador único real del cliente a nivel persona.
  - `customer_zip_code_prefix`: Prefijo del código postal del cliente.
  - `customer_city`: Ciudad del cliente.
  - `customer_state`: Estado del cliente.

## 10. WA_Fn-UseC_-Telco-Customer-Churn
- **Clave Primaria:** customerID
- **Claves Foráneas:** Ninguna
- **Granularidad:** Una fila = Un cliente único de telecomunicaciones con sus servicios y estado de churn.
- **Descripción de columnas:**
  - `customerID`: Identificador único de cada cliente.
  - `gender`: Género del cliente.
  - `SeniorCitizen`: Indica si es de la tercera edad (1=Sí, 0=No).
  - `Partner`: Indica si tiene pareja.
  - `Dependents`: Indica si tiene dependientes económicos.
  - `tenure`: Meses de antigüedad en la compañía.
  - `PhoneService`: Indica si contratóp servicio telefónico.
  - `MultipleLines`: Indica si cuenta con múltiples líneas.
  - `InternetService`: Tipo de servicio de internet (DSL, Fiber optic, No).
  - `OnlineSecurity`: Servicio de seguridad en línea activado.
  - `OnlineBackup`: Respaldo en línea activado.
  - `DeviceProtection`: Protección de dispositivo activada.
  - `TechSupport`: Soporte técnico activado.
  - `StreamingTV`: Servicio de TV por streaming activado.
  - `StreamingMovies`: Servicio de películas por streaming activado.
  - `Contract`: Plazo del contrato (Month-to-month, One year, Two year).
  - `PaperlessBilling`: Facturación electrónica/digital.
  - `PaymentMethod`: Método de pago configurado.
  - `MonthlyCharges`: Cobro mensual.
  - `TotalCharges`: Cobro total acumulado.
  - `Churn`: Indica si canceló el servicio (Yes/No).
