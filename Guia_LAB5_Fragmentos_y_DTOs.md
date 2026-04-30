# 🧩 Guía LAB5: Fragmentos Thymeleaf y DTOs

Seguiremos con la temática que ya conoces: **Tienda de Celulares** (marca + celular). Así no tienes que aprender tema nuevo y concepto nuevo al mismo tiempo.

---

# PARTE 1: Fragmentos Thymeleaf

## ¿Cuál es el problema?

Imagina que tienes 5 páginas HTML y todas tienen la misma barra de navegación:

```
listaCelulares.html  → tiene el <nav>
formCelular.html     → COPIA del <nav>
detallecelular.html  → OTRA COPIA del <nav>
...
```

Si el profesor te pide cambiar el color del nav... tienes que editarlo en los 5 archivos. 😩
**Los Fragmentos solucionan esto.**

---

## La Solución: Fragmentos en 2 pasos

### PASO 1: Crear el archivo de fragmentos

Crea un archivo `fragments.html` en `src/main/resources/templates/`.
Este archivo **no es una página visible**, solo es un contenedor de piezas reutilizables.

```html
<!-- src/main/resources/templates/fragments.html -->
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<body>

    <!-- 
        th:fragment="nombreQueYoElijo"
        Define la pieza reutilizable. El nombre lo pones tú.
    -->
    <nav th:fragment="navbar">
        <ul>
            <li><a href="/celulares/lista">📱 Celulares</a></li>
            <li><a href="/marcas/lista">🏷️ Marcas</a></li>
        </ul>
        <hr>
    </nav>

    <!-- Puedes tener VARIOS fragmentos en el mismo archivo -->
    <footer th:fragment="footer">
        <hr>
        <p>© 2026 - Tienda de Celulares GTICS</p>
    </footer>

</body>
</html>
```

---

### PASO 2: Usar el fragmento en otras páginas

En cualquier otro HTML, en vez de escribir el nav completo, usas `th:replace`:

```html
<!-- src/main/resources/templates/listaCelulares.html -->
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
    <title>Lista de Celulares</title>
</head>
<body>

    <!-- 
        th:replace="~{fragments :: navbar}"
                        ↑              ↑
                nombre del archivo   nombre del th:fragment
        
        Esto REEMPLAZA este div completo con el contenido del fragmento.
    -->
    <div th:replace="~{fragments :: navbar}"></div>

    <h1>Lista de Celulares</h1>
    <table border="1">
        <thead>
            <tr><th>Modelo</th><th>Precio</th><th>Marca</th></tr>
        </thead>
        <tbody>
            <tr th:each="cel : ${listaCelulares}">
                <td th:text="${cel.modelo}"></td>
                <td th:text="${cel.precio}"></td>
                <td th:text="${cel.marca.nombre}"></td>
            </tr>
        </tbody>
    </table>

    <!-- Reutilizamos el footer también -->
    <div th:replace="~{fragments :: footer}"></div>

</body>
</html>
```

---

## ⚡ th:replace vs th:insert — ¿Cuál usar?

| | `th:replace` | `th:insert` |
|---|---|---|
| **¿Qué hace?** | **Elimina** el `<div>` donde lo pones y lo sustituye por el fragmento | **Inserta** el fragmento DENTRO del `<div>` donde lo pones |
| **Resultado HTML** | `<nav>...</nav>` (el div desaparece) | `<div><nav>...</nav></div>` (el div queda como envoltorio) |
| **¿Cuál usar en el lab?** | ✅ **Este** — más limpio |  |

---

## 🧠 Regla de Oro: La Sintaxis del th:replace

```
th:replace="~{ nombreArchivo :: nombreFragmento }"
               ↑                  ↑
       Sin extensión .html    El que pusiste en th:fragment=""
```

**Si el archivo está en una subcarpeta:**
```
th:replace="~{ layouts/base :: navbar }"
```

---

# PARTE 2: DTOs (Data Transfer Objects)

## ¿Cuál es el problema?

Tienes dos tablas: `marca` y `celular`. Un `Celular` tiene: id, modelo, precio, color, y una relación `@ManyToOne` con `Marca`.

Ahora el profesor te pide: **"Muestra una lista con el nombre de la marca y la cantidad de celulares que tiene cada una."**

Eso no es ni un `Celular` ni una `Marca`... es **información combinada de ambas tablas**. No existe una Entity para eso.

**La solución: crear un DTO** — una clase simple de Java que solo almacena el resultado de esa consulta especial.

---

## La Solución: DTOs en 3 pasos

### PASO 1: Crear la clase DTO

Crea una carpeta `dto` dentro de tu paquete principal y crea la clase.
**OJO: No tiene `@Entity`, no mapea ninguna tabla.** Es una clase Java pura.

```java
// src/main/java/com/example/tienda/dto/MarcaConConteoDTO.java
package com.example.tienda.dto;

// No tiene @Entity, @Table, ni nada de JPA.
// Solo tiene atributos y UN constructor que coincide con tu @Query.
public class MarcaConConteoDTO {

    private String nombreMarca;
    private Long cantidadCelulares;

    // ⚠️ OBLIGATORIO: El constructor debe recibir los datos en el mismo
    // orden en que los seleccionas en el @Query.
    public MarcaConConteoDTO(String nombreMarca, Long cantidadCelulares) {
        this.nombreMarca = nombreMarca;
        this.cantidadCelulares = cantidadCelulares;
    }

    // Getters (o usa @Getter de Lombok en la clase)
    public String getNombreMarca() { return nombreMarca; }
    public Long getCantidadCelulares() { return cantidadCelulares; }
}
```

> [!TIP]
> Si tienes Lombok en el proyecto, puedes reemplazar el constructor y getters
> con `@AllArgsConstructor` y `@Getter` encima de la clase. ¡Mucho más rápido!

---

### PASO 2: Crear la Query en el Repository

En tu `MarcaRepository.java` (o `CelularRepository.java`), agregas un método con `@Query`.

```java
// src/main/java/com/example/tienda/repository/MarcaRepository.java
package com.example.tienda.repository;

import com.example.tienda.dto.MarcaConConteoDTO;
import com.example.tienda.entity.Marca;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface MarcaRepository extends JpaRepository<Marca, Integer> {

    // @Query usa JPQL (Java Persistence Query Language), NO SQL puro.
    // Las entidades y atributos van con su nombre en Java (Marca, Celular),
    // NO con el nombre de la tabla en MySQL (marca, celular).
    @Query("SELECT new com.example.tienda.dto.MarcaConConteoDTO(" +
               "m.nombre, COUNT(c.id)" +
           ") " +
           "FROM Marca m LEFT JOIN Celular c ON c.marca = m " +
           "GROUP BY m.id, m.nombre")
    List<MarcaConConteoDTO> obtenerMarcasConConteo();
}
```

### 🔍 Desglosando el @Query

```sql
SELECT new com.example.paquete.dto.MiDTO(campo1, campo2)
       ↑
       Así le dices a JPA: "construye un objeto de ESTA clase con estos datos"
       El paquete completo es obligatorio.

FROM Marca m         → Nombre de la Entity Java, no la tabla SQL
LEFT JOIN Celular c  → La Entity relacionada
ON c.marca = m       → El atributo @ManyToOne de Celular
GROUP BY m.id        → Agrupamos para que COUNT funcione
```

---

### PASO 3: Usar el DTO en el Controller y la Vista

**En el Controller:**
```java
@GetMapping("/marcas/reporte")
public String reporteMarcas(Model model) {
    // El repository devuelve directamente una lista de DTOs
    List<MarcaConConteoDTO> reporte = marcaRepository.obtenerMarcasConConteo();
    model.addAttribute("reporte", reporte);
    return "reporteMarcas"; // nombre del HTML
}
```

**En el HTML (`reporteMarcas.html`):**
```html
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head><title>Reporte de Marcas</title></head>
<body>

    <div th:replace="~{fragments :: navbar}"></div>

    <h1>Reporte: Celulares por Marca</h1>

    <table border="1">
        <thead>
            <tr>
                <th>Marca</th>
                <th>Cantidad de Celulares</th>
            </tr>
        </thead>
        <tbody>
            <!-- Itera igual que siempre, pero ahora los atributos
                 son los del DTO, no los de la Entity -->
            <tr th:each="item : ${reporte}">
                <td th:text="${item.nombreMarca}"></td>
                <td th:text="${item.cantidadCelulares}"></td>
            </tr>
        </tbody>
    </table>

</body>
</html>
```

---

# 📋 Resumen Visual — Los 2 Temas en una Tabla

| | Fragmentos Thymeleaf | DTOs |
|---|---|---|
| **¿Para qué?** | Reutilizar HTML (nav, footer) | Combinar datos de varias tablas |
| **Archivo nuevo** | `fragments.html` en `templates/` | `MiDTO.java` en paquete `dto/` |
| **Palabra clave definir** | `th:fragment="nombre"` en el HTML | Constructor con los campos que necesitas |
| **Palabra clave usar** | `th:replace="~{archivo :: nombre}"` | `@Query("SELECT new paquete.DTO(...)...")` en Repository |
| **Toca el Controller?** | ❌ No | ✅ Sí, usa `List<MiDTO>` |
| **Toca `@Entity`?** | ❌ No | ❌ No (el DTO no es una Entity) |

---

# ✅ Checklist para el Laboratorio

### Fragmentos:
- [ ] ¿Creé `fragments.html` en la carpeta `templates/`?
- [ ] ¿Puse `th:fragment="nombreExacto"` en el elemento a reutilizar?
- [ ] ¿En las otras páginas usé `th:replace="~{fragments :: nombreExacto}"`?
- [ ] ¿El nombre del archivo es sin la extensión `.html` en el `th:replace`?

### DTOs:
- [ ] ¿Mi clase DTO NO tiene `@Entity`?
- [ ] ¿El constructor del DTO recibe los campos en el mismo orden del `SELECT`?
- [ ] ¿En el `@Query` usé `new paquete.completo.dto.MiClaseDTO(...)`?
- [ ] ¿En el `@Query` usé nombres de **Entities Java** (no tablas SQL)?
- [ ] ¿En el HTML accedo a los campos del DTO igual que a cualquier objeto (`${item.nombreMarca}`)?
