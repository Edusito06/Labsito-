# ✅ Solución Guiada — Lab 1: Biblioteca Virtual
> Se resuelven los Ejercicios 1 y 2 paso a paso.
> Con esa base, tú resuelves el 3 y el 4 solo.

---

## 0. Configuración Inicial

### `application.properties`
```properties
spring.datasource.url=jdbc:mysql://localhost:3306/biblioteca
spring.datasource.username=root
spring.datasource.password=
spring.jpa.hibernate.ddl-auto=none
spring.jpa.show-sql=true
```

---

## Estructura de carpetas que tendrás al final

```
src/main/java/com/example/biblioteca/
├── dto/
│   └── AutorReporteDTO.java        ← Ej 4
├── entity/
│   ├── Autor.java
│   └── Libro.java
├── repository/
│   ├── AutorRepository.java
│   └── LibroRepository.java
└── controller/
    ├── AutorController.java
    └── LibroController.java

src/main/resources/templates/
├── fragments.html                  ← Ej 1 ⭐
├── autores/
│   ├── lista.html                  ← Ej 3
│   └── reporte.html                ← Ej 4 ⭐
└── libros/
    └── lista.html                  ← Ej 2
```

---

# EJERCICIO 1 — NavBar con Fragmentos ⭐

## ¿Qué vamos a hacer?
Crear UN SOLO archivo `fragments.html` con el navbar, y luego usarlo
en todas las páginas con `th:replace` para no repetir código.

---

### Paso 1: Crear `fragments.html`

📁 Ruta: `src/main/resources/templates/fragments.html`

```html
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<body>

    <!--
        th:fragment="navbar"  →  Le pones un nombre a esta pieza.
        Ese nombre es el que usarás en th:replace en otras páginas.
    -->
    <nav th:fragment="navbar">
        <a href="/libros/lista">📚 Libros</a> |
        <a href="/autores/lista">👤 Autores</a> |
        <a href="/autores/reporte">📊 Reporte</a>
        <hr>
    </nav>

</body>
</html>
```

> ¿Por qué el `<html>` y `<body>`? Thymeleaf los requiere para que el
> archivo sea HTML válido. Al momento de insertar el fragmento en otra
> página, Thymeleaf solo toma el `<nav>`, no el html/body.

---

### Paso 2: Usar el fragmento en otra página

En **cualquier HTML** donde quieras el navbar, escribes esta línea:

```html
<div th:replace="~{fragments :: navbar}"></div>
<!--              ↑ nombre del archivo  ↑ nombre del th:fragment -->
```

Lo que hace: **elimina** ese `<div>` y lo reemplaza con el `<nav>` de `fragments.html`.

> ✅ Listo. Con eso el Ejercicio 1 está resuelto. Solo asegúrate de que
> esa línea aparezca en la lista de libros, lista de autores Y reporte.

---

# EJERCICIO 2 — Listar Libros

## ¿Qué vamos a hacer?
Mostrar una tabla con todos los libros. La columna "Autor" viene de la
relación `@ManyToOne` que une `Libro` con `Autor`.

---

### Paso 1: Crear la Entity `Autor.java`

📁 Ruta: `src/main/java/com/example/biblioteca/entity/Autor.java`

```java
package com.example.biblioteca.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "autor")
public class Autor {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_autor")
    private Integer id;

    private String nombre;  // columna "nombre" en MySQL → mismo nombre, no necesita @Column
    private String pais;    // columna "pais" en MySQL
}
```

> **¿Por qué `@Column(name = "id_autor")`?**
> Porque en tu tabla MySQL la columna se llama `id_autor`, pero en Java
> pusiste `private Integer id`. Si los nombres no coinciden, debes aclararlo.
> Si en Java hubieras puesto `private Integer idAutor`, tampoco coincidiría
> porque JPA espera `id_autor` (con guión bajo) vs `idAutor` (camelCase).

---

### Paso 2: Crear la Entity `Libro.java`

📁 Ruta: `src/main/java/com/example/biblioteca/entity/Libro.java`

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

    // MUCHOS libros pertenecen a UN autor → @ManyToOne
    // La FK en MySQL se llama "id_autor" → eso va en @JoinColumn
    @ManyToOne
    @JoinColumn(name = "id_autor")
    private Autor autor;  // ← El tipo es Autor (el objeto completo), NO un Integer
}
```

> **La regla de oro de `@ManyToOne`:**
> - `@ManyToOne` → "esta tabla tiene una FK"
> - `@JoinColumn(name = "id_autor")` → "el nombre EXACTO de la columna FK en MySQL"
> - `private Autor autor` → "el tipo de dato es la Entity relacionada, no un Integer"

---

### Paso 3: Crear los Repositories

📁 `src/main/java/com/example/biblioteca/repository/AutorRepository.java`
```java
package com.example.biblioteca.repository;

import com.example.biblioteca.entity.Autor;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface AutorRepository extends JpaRepository<Autor, Integer> {
    // JpaRepository<Autor, Integer>
    //               ↑       ↑
    //           La Entity  El tipo de dato del @Id
}
```

📁 `src/main/java/com/example/biblioteca/repository/LibroRepository.java`
```java
package com.example.biblioteca.repository;

import com.example.biblioteca.entity.Libro;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface LibroRepository extends JpaRepository<Libro, Integer> {
}
```

> Los repositories son interfaces vacías. Solo con heredar de `JpaRepository`
> ya tienes `findAll()`, `save()`, `findById()`, etc. Spring los implementa solo.

---

### Paso 4: Crear `LibroController.java`

📁 `src/main/java/com/example/biblioteca/controller/LibroController.java`

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

    // Inyección por constructor (la forma correcta en Spring)
    final LibroRepository libroRepository;

    public LibroController(LibroRepository libroRepository) {
        this.libroRepository = libroRepository;
    }

    @GetMapping("/lista")
    public String listarLibros(Model model) {
        // 1. Pedir todos los libros al repositorio
        // 2. Meterlos en el model con un nombre ("listaLibros")
        // 3. Ese nombre es el que usarás en el HTML con th:each
        model.addAttribute("listaLibros", libroRepository.findAll());
        return "libros/lista";  // → busca templates/libros/lista.html
    }
}
```

> **¿Por qué `return "libros/lista"`?**
> Porque el HTML está en `templates/libros/lista.html`.
> Thymeleaf busca relativo a la carpeta `templates/`.

---

### Paso 5: Crear la vista `libros/lista.html`

📁 `src/main/resources/templates/libros/lista.html`

```html
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
    <title>Catálogo de Libros</title>
</head>
<body>

    <!-- EJERCICIO 1: El navbar viene de fragments.html -->
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
            <!--
                th:each="libro : ${listaLibros}"
                  ↑ variable local   ↑ nombre del model.addAttribute
            -->
            <tr th:each="libro : ${listaLibros}">
                <td th:text="${libro.id}"></td>
                <td th:text="${libro.titulo}"></td>
                <td th:text="${libro.precio}"></td>

                <!--
                    Como Libro tiene un objeto Autor adentro,
                    accedemos con: libro.autor.nombre
                    Thymeleaf llama al getAutor().getNombre() automáticamente
                -->
                <td th:text="${libro.autor.nombre}"></td>
            </tr>
        </tbody>
    </table>

</body>
</html>
```

> **El truco de la relación en el HTML:**
> `${libro.autor.nombre}` funciona porque:
> 1. `libro` es un objeto `Libro`
> 2. `Libro` tiene `private Autor autor` con `@ManyToOne`
> 3. Spring JPA ya cargó el autor junto al libro
> 4. `nombre` es el atributo de `Autor`

---

# 🧩 AHORA TÚ — Ejercicios 3 y 4

Con todo lo que viste arriba, tienes las herramientas para hacer los dos que quedan.

---

## Ejercicio 3 — Lista de Autores (pistas)

Es exactamente igual que el Ejercicio 2 pero más fácil porque no hay relación.
Necesitas:
- [ ] `AutorController.java` con un `@GetMapping("/lista")` que pase la lista de autores al model
- [ ] `autores/lista.html` con una tabla que muestre `id`, `nombre` y `pais`
- [ ] No olvides poner el `th:replace` del navbar

---

## Ejercicio 4 — Reporte con DTO (pistas)

Este es el más importante. El flujo es:

```
1. Crea la clase  →  AutorReporteDTO.java  (en paquete dto/)
2. Crea la query  →  @Query en AutorRepository
3. Úsala          →  AutorController, nuevo @GetMapping("/reporte")
4. Muéstrala      →  autores/reporte.html con th:each
```

**Pista para el DTO:**
```java
// La clase tiene exactamente estos 4 campos y un constructor:
public class AutorReporteDTO {
    private String nombre;
    private String pais;
    private Long cantidadLibros;    // COUNT devuelve Long
    private Double precioPromedio;  // AVG devuelve Double
    // constructor con los 4 campos...
    // getters...
}
```

**Pista para el @Query:**
```java
@Query("SELECT new com.example.biblioteca.dto.AutorReporteDTO(" +
       "a.nombre, a.pais, COUNT(l.id), AVG(l.precio)) " +
       "FROM Autor a LEFT JOIN Libro l ON l.autor = a " +
       "GROUP BY a.id, a.nombre, a.pais")
List<AutorReporteDTO> obtenerReporte();
```

> ⚠️ `LEFT JOIN` en vez de `JOIN` para que aparezca Jorge Amado aunque
> tuviera 0 libros. Con `JOIN` normal, los autores sin libros desaparecen.

**Pista para el HTML:**
```html
<tr th:each="item : ${reporte}">
    <td th:text="${item.nombre}"></td>
    <td th:text="${item.pais}"></td>
    <td th:text="${item.cantidadLibros}"></td>
    <td th:text="${item.precioPromedio}"></td>
</tr>
```

---

## ✅ Resultado esperado del Ejercicio 4

| Autor | País | N° Libros | Precio Promedio |
|---|---|---|---|
| Gabriel García Márquez | Colombia | 3 | 37.80 |
| Mario Vargas Llosa | Perú | 4 | 45.00 |
| Isabel Allende | Chile | 2 | 36.00 |
| Jorge Amado | Brasil | 1 | 36.00 |
| Julio Cortázar | Argentina | 3 | 34.33 |

---

¡Cuando termines los ejercicios 3 y 4, avísame y revisamos tu código! 🚀
