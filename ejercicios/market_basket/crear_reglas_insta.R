library(tidyverse)
library(arules)
library(here)

#Se requeren unos 6G de memoria para correr este script
#Correr desde el directorio base del repositorio
#Necesitas bajar el archivo order_products__prior.csv
# checa el readme en la carpeta datos/instacart-kaggle

# leer transacciones
ruta_trans <- here("datos", "instacart-kaggle","order_products__prior.csv")
trans_tbl <- read_csv(ruta_trans, col_types = "iiii")
trans <- as(split(pull(trans_tbl, "product_id"), pull(trans_tbl,"order_id")), "transactions")
trans
inspect(trans[1:2])

# nombres de productos
productos_tbl <- read_csv(here("datos", "instacart-kaggle/products.csv"), col_types = "icii") %>% 
  select(product_id, product_name) 

frecs_tbl <- trans_tbl %>% left_join(productos_tbl) %>% group_by(product_name, product_id) %>% 
  tally()

# soporte mínimo y conf
min_soporte <- 0.0001
min_conf <- 0.10
sprintf("Mínimo soporte absoluto: %0.f", length(trans) * min_soporte)

pars <- list(supp = min_soporte, confidence = min_conf, target = "rules", 
             ext = TRUE, minlen = 2, maxtime = 30)
reglas <- apriori(trans, parameter = pars)
sprintf("Se encontraron %0.f reglas", length(reglas))
agregar_hyperlift <- function(reglas, trans){
  quality(reglas) <- cbind(quality(reglas), 
    hyper_lift = interestMeasure(reglas, measure = "hyperLift", transactions = trans))
  reglas
}
reglas <- agregar_hyperlift(reglas, trans)
write_rds(reglas, here("datos", "reglas_query.rds"))

############
reglas <- read_rds(here("datos", "reglas_query.rds"))

productos_tbl <- read_csv(here("datos", "instacart-kaggle/products.csv"), col_types = "icii") %>% 
  select(product_id, product_name) 


obtener_nombres <- function(canasta){
  tibble(product_id = as.integer(canasta)) %>% inner_join(productos_tbl) %>% pull(product_name)
}

obtener_recoms <- function(canasta){
  recoms <- subset(reglas, lhs %ain% canasta) %>% 
    DATAFRAME %>% 
    group_by(RHS) %>% top_n(5, wt = hyper_lift) %>% 
    mutate(product_id = str_sub(RHS, 2, -2) %>% as.integer) %>% 
    left_join(productos_tbl) %>% 
    select(LHS, RHS, product_id, product_name, confidence, hyper_lift, count) %>% 
    arrange(desc(hyper_lift))
}


canasta <- c("31717", 	"47766")
obtener_nombres(canasta)
recoms <- obtener_recoms(canasta)
recoms
#View(recoms)

canasta <- c("30529")
obtener_nombres(canasta)
recoms <- obtener_recoms(canasta)
recoms
#View(recoms)

