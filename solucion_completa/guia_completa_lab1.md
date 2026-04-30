# ✅ Solución Completa — Lab 1: Biblioteca Virtual
### Los 4 ejercicios resueltos paso a paso

---

## 📁 Dónde está cada archivo

Todos los archivos de código están en:
```
LAB4/PRACTICA_LAB1/solucion_completa/
├── entity/
│   ├── Autor.java
│   └── Libro.java
├── dto/
│   └── AutorReporteDTO.java
├── repository/
│   ├── AutorRepository.java
│   └── LibroRepository.java
├── controller/
│   ├── AutorController.java
│   └── LibroController.java
└── templates/
    ├── fragments.html
    ├── libros/
    │   └── lista.html
    └── autores/
        ├── lista.html
        └── reporte.html
```

> En tu proyecto de IntelliJ, los `.java` van en:
> `src/main/java/com/example/biblioteca/[carpeta]/`
>
> Los `.html` van en:
> `src/main/resources/templates/[carpeta]/`

---

## ⚙️ application.properties

```properties
spring.datasource.url=jdbc:mysql://localhost:3306/biblioteca
spring.datasource.username=root
spring.datasource.password=
spring.jpa.hibernate.ddl-auto=none
spring.jpa.show-sql=true
```

---

# EJERCICIO 1 — NavBar con Fragmentos

## El archivo `fragments.html`
📁 Va en: `src/main/resources/templates/fragments.html`

```html
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<body>
    <nav th:fragment="navbar">
        <a href="/libros/lista">📚 Libros</a> |
        <a href="/autores/lista">👤 Autores</a> |
        <a href="/autores/reporte">📊 Reporte</a>
        <hr>
    </nav>
</body>
</html>
```

**¿Cómo funciona?**
- `th:fragment="navbar"` → le pones un nombre a esa pieza de HTML
- Este archivo no es una página que el usuario visita, es solo un contenedor

## ¿Cómo se usa en otra página?
En CUALQUIER otro HTML, donde quieras que aparezca el nav, pones:

```html
<div th:replace="~{fragments :: navbar}"></div>
<!--              ↑ nombre del archivo  ↑ nombre del th:fragment -->
```

Thymeleaf borra ese `<div>` y lo reemplaza con el `<nav>` definido arriba.

---

# EJERCICIO 2 — Lista de Libros

## Paso 1: `Autor.java`
📁 Va en: `src/main/java/com/example/biblioteca/entity/Autor.java`

```java
package com.example.biblioteca.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "autor")       // nombre exacto de la tabla en MySQL
public class Autor {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_autor") // la columna MySQL se llama id_autor, la variable id
    private Integer id;

    private String nombre;     // mismo nombre en MySQL → no necesita @Column
    private String pais;
}
```

---

## Paso 2: `Libro.java`
📁 Va en: `src/main/java/com/example/biblioteca/entity/Libro.java`

```java
package com.example.biblioteca.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "libro")
public class Libro {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_libro")
    private Integer id;

    private String titulo;
    private Double precio;

    @ManyToOne                      // MUCHOS libros → UN autor
    @JoinColumn(name = "id_autor")  // nombre exacto de la FK en MySQL
    private Autor autor;            // tipo: el objeto Autor, no un Integer
}
```

**La regla de `@ManyToOne`:**
| Anotación | Para qué sirve |
|---|---|
| `@ManyToOne` | Le dice a JPA que esta tabla tiene una FK |
| `@JoinColumn(name="id_autor")` | El nombre EXACTO de la columna FK en MySQL |
| `private Autor autor` | El tipo es la Entity, no un número |

---

## Paso 3: `LibroRepository.java`
📁 Va en: `src/main/java/com/example/biblioteca/repository/LibroRepository.java`

```java
package com.example.biblioteca.repository;

import com.example.biblioteca.entity.Libro;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface LibroRepository extends JpaRepository<Libro, Integer> {
    // Vacío — JpaRepository ya nos da findAll(), save(), findById(), etc.
}
```

---

## Paso 4: `LibroController.java`
📁 Va en: `src/main/java/com/example/biblioteca/controller/LibroController.java`

```java
package com.example.biblioteca.controller;

import com.example.biblioteca.repository.LibroRepository;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/libros")
public class LibroController {

    final LibroRepository libroRepository;

    public LibroController(LibroRepository libroRepository) {
        this.libroRepository = libroRepository;
    }

    @GetMapping("/lista")
    public String listarLibros(Model model) {
        model.addAttribute("listaLibros", libroRepository.findAll());
        return "libros/lista";   // busca templates/libros/lista.html
    }
}
```

---

## Paso 5: `libros/lista.html`
📁 Va en: `src/main/resources/templates/libros/lista.html`

```html
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head><title>Lista de Libros</title></head>
<body>

    <div th:replace="~{fragments :: navbar}"></div>

    <h1>Catálogo de Libros</h1>

    <table border="1">
        <thead>
            <tr>
                <th>ID</th>
                <th>Título</th>
                <th>Precio (S/.)</th>
                <th>Autor</th>
            </tr>
        </thead>
        <tbody>
            <tr th:each="libro : ${listaLibros}">
                <td th:text="${libro.id}"></td>
                <td th:text="${libro.titulo}"></td>
                <td th:text="${libro.precio}"></td>
                <td th:text="${libro.autor.nombre}"></td>
            </tr>
        </tbody>
    </table>

</body>
</html>
```

**Truco:** `${libro.autor.nombre}` funciona porque Libro tiene `private Autor autor`
con `@ManyToOne`. Spring JPA cargó el autor automáticamente.

---

# EJERCICIO 3 — Lista de Autores

## `AutorRepository.java`
📁 Va en: `src/main/java/com/example/biblioteca/repository/AutorRepository.java`

```java
package com.example.biblioteca.repository;

import com.example.biblioteca.dto.AutorReporteDTO;
import com.example.biblioteca.entity.Autor;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface AutorRepository extends JpaRepository<Autor, Integer> {

    // El @Query del Ejercicio 4 también vive aquí
    @Query("SELECT new com.example.biblioteca.dto.AutorReporteDTO(" +
           "a.nombre, a.pais, COUNT(l.id), AVG(l.precio)) " +
           "FROM Autor a LEFT JOIN Libro l ON l.autor = a " +
           "GROUP BY a.id, a.nombre, a.pais")
    List<AutorReporteDTO> obtenerReporte();
}
```

## `AutorController.java`
📁 Va en: `src/main/java/com/example/biblioteca/controller/AutorController.java`

```java
package com.example.biblioteca.controller;

import com.example.biblioteca.repository.AutorRepository;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/autores")
public class AutorController {

    final AutorRepository autorRepository;

    public AutorController(AutorRepository autorRepository) {
        this.autorRepository = autorRepository;
    }

    // Ejercicio 3
    @GetMapping("/lista")
    public String listarAutores(Model model) {
        model.addAttribute("listaAutores", autorRepository.findAll());
        return "autores/lista";
    }

    // Ejercicio 4
    @GetMapping("/reporte")
    public String reporteAutores(Model model) {
        model.addAttribute("reporte", autorRepository.obtenerReporte());
        return "autores/reporte";
    }
}
```

## `autores/lista.html`
📁 Va en: `src/main/resources/templates/autores/lista.html`

```html
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head><title>Lista de Autores</title></head>
<body>

    <div th:replace="~{fragments :: navbar}"></div>

    <h1>Lista de Autores</h1>

    <table border="1">
        <thead>
            <tr>
                <th>ID</th>
                <th>Nombre</th>
                <th>País</th>
            </tr>
        </thead>
        <tbody>
            <tr th:each="autor : ${listaAutores}">
                <td th:text="${autor.id}"></td>
                <td th:text="${autor.nombre}"></td>
                <td th:text="${autor.pais}"></td>
            </tr>
        </tbody>
    </table>

</body>
</html>
```

---

# EJERCICIO 4 — Reporte con DTO ⭐

Este es el más importante. Implica 4 piezas nuevas:

## `AutorReporteDTO.java`
📁 Va en: `src/main/java/com/example/biblioteca/dto/AutorReporteDTO.java`

```java
package com.example.biblioteca.dto;

// ⚠️ Sin @Entity — no es una tabla, es solo un contenedor de datos
public class AutorReporteDTO {

    private String nombre;
    private String pais;
    private Long cantidadLibros;    // COUNT() devuelve Long
    private Double precioPromedio;  // AVG() devuelve Double

    // El constructor DEBE recibir los campos en el mismo
    // orden que los escribes en el SELECT del @Query
    public AutorReporteDTO(String nombre, String pais,
                           Long cantidadLibros, Double precioPromedio) {
        this.nombre = nombre;
        this.pais = pais;
        this.cantidadLibros = cantidadLibros;
        this.precioPromedio = precioPromedio;
    }

    // Getters (Thymeleaf los necesita para ${item.nombre}, etc.)
    public String getNombre() { return nombre; }
    public String getPais() { return pais; }
    public Long getCantidadLibros() { return cantidadLibros; }
    public Double getPrecioPromedio() { return precioPromedio; }
}
```

## El @Query en `AutorRepository.java`

```java
@Query("SELECT new com.example.biblioteca.dto.AutorReporteDTO(" +
       "a.nombre, a.pais, COUNT(l.id), AVG(l.precio)) " +
       "FROM Autor a LEFT JOIN Libro l ON l.autor = a " +
       "GROUP BY a.id, a.nombre, a.pais")
List<AutorReporteDTO> obtenerReporte();
```

**Desglose del @Query:**
| Parte | Explicación |
|---|---|
| `new com.example...DTO(...)` | Construye un objeto DTO con esos datos |
| `FROM Autor a` | Nombre de la **Entity Java**, no de la tabla MySQL |
| `LEFT JOIN Libro l ON l.autor = a` | Une con Libro por la relación @ManyToOne |
| `COUNT(l.id)` | Cuenta libros por autor |
| `AVG(l.precio)` | Promedio de precios |
| `GROUP BY a.id, a.nombre, a.pais` | Agrupa para que COUNT y AVG funcionen |

> ⚠️ `LEFT JOIN` (no `JOIN`) → para que aparezcan autores aunque tengan 0 libros

## `autores/reporte.html`
📁 Va en: `src/main/resources/templates/autores/reporte.html`

```html
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head><title>Reporte de Autores</title></head>
<body>

    <div th:replace="~{fragments :: navbar}"></div>

    <h1>Reporte: Libros por Autor</h1>

    <table border="1">
        <thead>
            <tr>
                <th>Autor</th>
                <th>País</th>
                <th>N° Libros</th>
                <th>Precio Promedio (S/.)</th>
            </tr>
        </thead>
        <tbody>
            <tr th:each="item : ${reporte}">
                <td th:text="${item.nombre}"></td>
                <td th:text="${item.pais}"></td>
                <td th:text="${item.cantidadLibros}"></td>
                <td th:text="${#numbers.formatDecimal(item.precioPromedio, 1, 2)}"></td>
            </tr>
        </tbody>
    </table>

</body>
</html>
```

**Nota:** `${#numbers.formatDecimal(item.precioPromedio, 1, 2)}` → muestra
el promedio con exactamente 2 decimales (ej: 37.80 en vez de 37.8000001)

---

# 🧪 Resultado esperado

### `/libros/lista`
| ID | Título | Precio | Autor |
|---|---|---|---|
| 1 | Cien años de soledad | 45.0 | Gabriel García Márquez |
| ... | ... | ... | ... |

### `/autores/lista`
| ID | Nombre | País |
|---|---|---|
| 1 | Gabriel García Márquez | Colombia |
| ... | ... | ... |

### `/autores/reporte` (DTO)
| Autor | País | N° Libros | Precio Promedio |
|---|---|---|---|
| Gabriel García Márquez | Colombia | 3 | 37.80 |
| Mario Vargas Llosa | Perú | 4 | 45.00 |
| Isabel Allende | Chile | 2 | 36.00 |
| Jorge Amado | Brasil | 1 | 36.00 |
| Julio Cortázar | Argentina | 3 | 34.33 |

---

# 🔑 Resumen de lo aprendido

| Concepto | Dónde se aplica | Código clave |
|---|---|---|
| **Fragmento** | `fragments.html` | `th:fragment="navbar"` |
| **Usar fragmento** | Todos los HTML | `th:replace="~{fragments :: navbar}"` |
| **Relación** | `Libro.java` | `@ManyToOne` + `@JoinColumn` |
| **DTO** | `AutorReporteDTO.java` | Clase sin `@Entity`, con constructor |
| **Query DTO** | `AutorRepository.java` | `@Query("SELECT new paquete.DTO(...)")` |
| **Mostrar DTO** | `reporte.html` | `${item.campo}` igual que cualquier objeto |
