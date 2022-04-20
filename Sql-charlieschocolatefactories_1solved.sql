CREATE DATABASE Manufacturer;

USE Manufacturer


CREATE TABLE product
(
prod_id INT NOT NULL,
prod_name VARCHAR(50) NOT NULL,
quantity INT NOT NULL,
CONSTRAINT product_pk PRIMARY KEY (prod_id)
)
CREATE TABLE component
(
comp_id INT NOT NULL,
comp_name VARCHAR(50) NOT NULL,
description VARCHAR(50) NULL,
quantity_comp INT NOT NULL,
CONSTRAINT component_pk PRIMARY KEY (comp_id)
)
CREATE TABLE supplier
(
supp_id INT NOT NULL,
supp_name VARCHAR(50) NOT NULL,
supp_location VARCHAR(50) NOT NULL,
supp_country VARCHAR(50) NOT NULL,
is_active BIT DEFAULT 1,
CONSTRAINT supplier_pk PRIMARY KEY(supp_id)
​
)
CREATE TABLE prod_comp
(
prod_id INT NOT NULL,
comp_id INT NOT NULL,
quantity_comp INT NOT NULL,
CONSTRAINT prod_comp_pk PRIMARY KEY(prod_id,comp_id),
CONSTRAINT prod_comp_fk_product FOREIGN KEY (prod_id) REFERENCES product(prod_id),
CONSTRAINT prod_comp_fk_component FOREIGN KEY(comp_id) REFERENCES component(comp_id)
)
CREATE TABLE comp_supp
(
supp_id INT NOT NULL,
comp_id INT NOT NULL,
order_date DATE NOT NULL,
quantity INT NOT NULL,
CONSTRAINT comp_supp_pk PRIMARY KEY(supp_id,comp_id),
CONSTRAINT comp_supp_fk_supplier FOREIGN KEY(supp_id) REFERENCES supplier(supp_id),
CONSTRAINT comp_supp_fk_component FOREIGN KEY(comp_id) REFERENCES component(comp_id)
)
