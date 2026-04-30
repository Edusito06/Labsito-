# 📚 LAB PRÁCTICA 1 — Biblioteca Virtual
### Temas: Fragmentos Thymeleaf + DTOs (Nivel Introductorio)
**Duración estimada:** 45-60 min

---

## 📖 Contexto

Una pequeña biblioteca necesita un sistema web para gestionar su catálogo.
Tienes dos tablas: `autor` y `libro`. Un autor puede tener muchos libros.

---

## 🗄️ Base de Datos

Usa el archivo `biblioteca.sql` que está en esta misma carpeta.
- Base de datos: `biblioteca`
- Tablas: `autor` y `libro`

---

## 🏗️ Estructura del proyecto

Crea un nuevo proyecto Spring Boot con las dependencias:
- Spring Web
- Thymeleaf
- Spring Data JPA
- MySQL Driver
- Lombok

Paquete base: `com.example.biblioteca`

---

## ✅ Ejercicios

---

### EJERCICIO 1 — NavBar con Fragmentos (3 pts)

Crea un archivo `fragments.html` dentro de `templates/` que contenga un fragmento
llamado `navbar` con los siguientes links de navegación:

| Link visible | Ruta |
|---|---|
| 📚 Libros | `/libros/lista` |
| 👤 Autores | `/autores/lista` |
| 📊 Reporte | `/autores/reporte` |

**Requisito:** Ese `navbar` debe aparecer en TODAS las páginas HTML del proyecto
usando `th:replace`. No copies el HTML del nav en cada página, usa el fragmento.

---

### EJERCICIO 2 — Listar Libros (3 pts)

Crea la página `/libros/lista` que muestre una tabla con:

| Columna | Fuente |
|---|---|
| ID | `libro.id` |
| Título | `libro.titulo` |
| Precio (S/.) | `libro.precio` |
| Autor | `libro.autor.nombre` ← **relación @ManyToOne** |

> **Tip:** Necesitas: `Libro.java` (con @ManyToOne a Autor), `Autor.java`,
> `LibroRepository`, `AutorRepository`, y `LibroController`.

---

### EJERCICIO 3 — Listar Autores (2 pts)

Crea la página `/autores/lista` que muestre una tabla simple con:
- ID del autor
- Nombre
- País

---

### EJERCICIO 4 — Reporte con DTO (4 pts) ⭐ TEMA NUEVO

Crea la página `/autores/reporte` que muestre una tabla con la siguiente
información **combinada** (no es ni un Autor ni un Libro, es un DTO):

| Columna | Descripción |
|---|---|
| Autor | Nombre del autor |
| País | País del autor |
| N° Libros | Cuántos libros tiene registrados |
| Precio Promedio | El promedio de precios de sus libros |

**Lo que debes crear:**
1. `AutorReporteDTO.java` en el paquete `dto/` — con los 4 campos y su constructor
2. Un método `@Query` en `AutorRepository` que use `SELECT new ...DTO(...)` con `COUNT` y `AVG`
3. Un `@GetMapping("/reporte")` en `AutorController` que pase la lista al HTML
4. La vista `reporteAutores.html` con el `th:replace` del navbar y la tabla con `th:each`

---

## 📐 Esquema de Rutas

```
GET /libros/lista      → listadoLibros.html
GET /autores/lista     → listadoAutores.html
GET /autores/reporte   → reporteAutores.html
```

---

## 🧠 Recordatorio Clave

**Para el DTO:**
```java
// En el @Query, el SELECT debe verse así:
"SELECT new com.example.biblioteca.dto.AutorReporteDTO(a.nombre, a.pais, COUNT(l.id), AVG(l.precio)) ..."
```

**Para los Fragmentos:**
```html
<!-- En fragments.html -->
<nav th:fragment="navbar"> ... </nav>

<!-- En cualquier otra página -->
<div th:replace="~{fragments :: navbar}"></div>
```

---

## 📦 Entregable

Cuando termines, avísame y revisaré tu código.
¡Mucho éxito! 💪
