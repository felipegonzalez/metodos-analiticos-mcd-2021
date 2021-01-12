# Métodos analiticos (ITAM, 2021)
Notas y material para el curso de Métodos Analíticos (Ciencia de Datos, ITAM).

- [Notas](https://metodos-analiticos-2021.netlify.app/). Estas notas son producidas
en un contenedor (con [imagen base de rocker](https://www.rocker-project.org, y limitado a unos 8G de memoria)  construido con el Dockerfile del repositorio:

```
docker build . -t ma-rstudio
docker run --rm -p 8787:8787 -p 4040:4040 -e PASSWORD=mipass -v /tu/carpeta/local:/home/rstudio/ma ma-rstudio
```

- Para correr las notas usa el script notas/\_build.sh dentro del contenedor. Abre el archivo notas/\_book/index.html para ver tu copia local de las notas.

- Todos los ejercicios y tareas corren también en ese contenedor. Es opcional usarlo,
pero si tienes problemas de reproducibilidad puedes intentarlo.

