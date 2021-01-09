# Dummy sparklyR script

# Attach libraries
library(sparklyr)
library(dplyr)
library(nycflights13)

# Connect
config <- spark_config()
# esta línea es necesaria para que la ui funcione en el contenedor:
config$`spark.env.SPARK_LOCAL_IP.local` <- "0.0.0.0"
# puedes ajustar si es necesario 
# la memoria según el tamaño de los datos y tus recursos:
#config$`sparklyr.shell.driver-memory` <- "8G"
sc <- spark_connect(master = "local", config = config)

# Copy weather to the instance
tbl_weather <- dplyr::copy_to(sc, nycflights13::weather, "weather", overwrite = TRUE)

# Collect it back
tbl_weather %>% collect()

# Create some functions
fun_implemented <- function(df, col) df %>% mutate({{col}} := tolower({{col}}))
fun_r_only <- function(df, col) df %>% mutate({{col}} := casefold({{col}}, upper = FALSE))
fun_hive_builtin <- function(df, col) df %>% mutate({{col}} := lower({{col}}))

# Run an example benchmark
microbenchmark::microbenchmark(
  times = 3, 
  hive_builtin = fun_hive_builtin(tbl_weather, origin) %>% collect(),
  translated_dplyr = fun_implemented(tbl_weather, origin) %>% collect()
)

