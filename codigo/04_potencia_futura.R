# Planificacion prospectiva, no potencia observada.
# Requiere datos_principales de codigo/01_inferencia.R.

alpha_plan <- 0.05
delta_plan <- 0.5 # Referencia diagnostica PROPUESTA por el equipo.

ya <- datos_principales$Y[datos_principales$X == 'Insuficientes']
yb <- datos_principales$Y[datos_principales$X == 'Justo alcanzan']
na <- length(ya)
nb <- length(yb)

# La desviacion del estudio actual se usa SOLO como dato piloto para
# planear una encuesta FUTURA. No es una desviacion oficialmente validada.
sigma_piloto <- sqrt(((na - 1) * var(ya) + (nb - 1) * var(yb)) / (na + nb - 2))

n_necesario <- function(potencia_objetivo, deff) {
  z_a <- qnorm(1 - alpha_plan / 2)
  z_b <- qnorm(potencia_objetivo)
  ceiling(2 * deff * sigma_piloto^2 * (z_a + z_b)^2 / delta_plan^2)
}

potencia_aprox <- function(n, deff) {
  ee_futuro <- sigma_piloto * sqrt(2 * deff / n)
  mu <- delta_plan / ee_futuro
  z <- qnorm(1 - alpha_plan / 2)
  pnorm(-z - mu) + pnorm(mu - z)
}

escenarios <- expand.grid(efecto_diseno = c(1.0, 1.5, 2.0, 3.0),
                          n_por_grupo = c(150L, 300L, 400L, 600L))
escenarios$sigma_piloto <- sigma_piloto
escenarios$delta_planificacion <- delta_plan
escenarios$alpha <- alpha_plan
escenarios$potencia_aproximada <- mapply(potencia_aprox,
                                         escenarios$n_por_grupo,
                                         escenarios$efecto_diseno)
write.csv2(escenarios,
           file.path(salidas, '04_escenarios_potencia.csv'), row.names = FALSE)

plan <- expand.grid(efecto_diseno = c(1.0, 2.0, 3.0),
                    potencia_objetivo = c(0.80, 0.90))
plan$sigma_piloto <- sigma_piloto
plan$delta_planificacion <- delta_plan
plan$alpha <- alpha_plan
plan$n_por_grupo <- mapply(n_necesario, plan$potencia_objetivo,
                            plan$efecto_diseno)
plan$potencia_aproximada <- mapply(potencia_aprox,
                                   plan$n_por_grupo,
                                   plan$efecto_diseno)
plan$n_total <- 2L * plan$n_por_grupo
write.csv2(plan, file.path(salidas, '03_potencia_futura.csv'),
           row.names = FALSE)

stopifnot(is.finite(sigma_piloto), sigma_piloto > 0,
          all(plan$potencia_aproximada >= plan$potencia_objetivo - 1e-8))
cat('Planificacion prospectiva: sigma piloto =', round(sigma_piloto, 4), '\n')
print(plan)
