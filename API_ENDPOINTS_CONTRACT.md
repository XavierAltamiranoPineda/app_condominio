# Contrato de API (Condominio REST API)

Este documento contiene la estructura exacta de las peticiones (Body) y respuestas (Responses) de la API RESTful construida en Spring Boot.

> **Nota:** Todos los endpoints protegidos devuelven siempre un `ApiResponse` genérico que envuelve la respuesta real dentro del atributo `"data"`. 
>
> Formato Base:
> ```json
> {
>   "success": true,
>   "timestamp": "2026-07-05T00:00:00.000",
>   "status": 200,
>   "message": "Mensaje de éxito",
>   "data": { ... } // Aquí va el objeto real o la lista
> }
> ```

---

## 1. Módulo: Autenticación (Auth)

### POST `/api/v1/auth/login`
**Body:**
```json
{
   "username": "admin",
   "password": "password"
}
```
**Respuesta (200 OK):**
```json
{
   "success": true,
   "status": 200,
   "message": "Login exitoso",
   "data": {
      "accessToken": "eyJhbG...",
      "refreshToken": "eyJhbG...",
      "tokenType": "Bearer",
      "expiresIn": 900000,
      "username": "admin",
      "roles": ["ROLE_ADMIN", "TICKETS_LEER"]
   }
}
```

---

## 2. Módulo: Condominios e Infraestructura

### GET `/api/v1/condominios`
**Respuesta (200 OK - Paginado):**
```json
{
   "success": true,
   "data": {
      "content": [
         {
            "id": 1,
            "nombre": "Condominio Los Pinos",
            "direccion": "Av. Principal 123",
            "telefono": "0999999999",
            "email": "admin@lospinos.com"
         }
      ],
      "pageable": {
         "pageNumber": 0,
         "pageSize": 10
      },
      "totalElements": 1
   }
}
```

### POST `/api/v1/condominios`
**Body:**
```json
{
   "nombre": "Condominio Los Pinos",
   "direccion": "Av. Principal 123",
   "telefono": "0999999999",
   "email": "admin@lospinos.com"
}
```
**Respuesta (201 Created):**
```json
{
   "success": true,
   "message": "Condominio creado exitosamente",
   "data": {
      "id": 1,
      "nombre": "Condominio Los Pinos",
      "direccion": "Av. Principal 123",
      "telefono": "0999999999",
      "email": "admin@lospinos.com"
   }
}
```

### GET `/api/v1/condominios/{id}/torres`
**Respuesta (200 OK - Paginado):**
```json
{
   "success": true,
   "data": {
      "content": [
         {
            "id": 1,
            "nombre": "Torre A",
            "pisos": 10
         }
      ]
   }
}
```

---

## 3. Módulo: Residentes y Personas

### POST `/api/v1/residentes`
**Body:**
```json
{
   "tipoIdentificacion": "CEDULA",
   "numeroIdentificacion": "1712345678",
   "nombres": "Juan Pablo",
   "apellidos": "Pérez",
   "correo": "juan@correo.com",
   "telefono": "0991112222",
   "esPropietario": true,
   "idUnidad": 5
}
```
**Respuesta (201 Created):**
```json
{
   "success": true,
   "data": {
      "id": 1,
      "persona": {
         "nombres": "Juan Pablo",
         "apellidos": "Pérez",
         "correo": "juan@correo.com"
      },
      "esPropietario": true,
      "fechaIngreso": "2026-07-05T10:00:00"
   }
}
```

---

## 4. Módulo: Tickets (Incidencias)

### POST `/api/v1/tickets`
**Body:**
```json
{
   "titulo": "Fuga de agua en pasillo",
   "descripcion": "El tubo del pasillo del piso 3 está goteando.",
   "idCategoria": 2,
   "prioridad": "ALTA"
}
```
**Respuesta (201 Created):**
```json
{
   "success": true,
   "data": {
      "id": 1,
      "titulo": "Fuga de agua en pasillo",
      "estado": "ABIERTO",
      "prioridad": "ALTA",
      "fechaCreacion": "2026-07-05T10:00:00",
      "creadoPor": "juan_perez"
   }
}
```

### GET `/api/v1/tickets/{id}/comentarios`
**Respuesta (200 OK):**
```json
{
   "success": true,
   "data": [
      {
         "id": 1,
         "mensaje": "El fontanero va en camino.",
         "autor": "Admin Condominio",
         "fechaCreacion": "2026-07-05T10:30:00"
      }
   ]
}
```

---

## 5. Módulo: Comunicados

### POST `/api/v1/comunicados`
**Body:**
```json
{
   "titulo": "Corte de luz programado",
   "mensaje": "Mañana de 9am a 11am se cortará la luz por mantenimiento.",
   "tipo": "MANTENIMIENTO",
   "importancia": "ALTA"
}
```
**Respuesta (201 Created):**
```json
{
   "success": true,
   "data": {
      "id": 1,
      "titulo": "Corte de luz programado",
      "tipo": "MANTENIMIENTO",
      "fechaPublicacion": "2026-07-05"
   }
}
```

---

## 6. Módulo: Financiero (Cuotas y Pagos)

### GET `/api/v1/cuotas`
**Respuesta (200 OK):**
```json
{
   "success": true,
   "data": {
      "content": [
         {
            "id": 101,
            "tipo": "ORDINARIA",
            "monto": 50.00,
            "mes": 7,
            "anio": 2026,
            "estado": "PENDIENTE",
            "fechaVencimiento": "2026-07-15"
         }
      ]
   }
}
```

### POST `/api/v1/pagos`
**Body:**
```json
{
   "idCuota": 101,
   "montoPagado": 50.00,
   "metodoPago": "TRANSFERENCIA",
   "referencia": "TRANSF-99887766",
   "fechaPago": "2026-07-05"
}
```
**Respuesta (201 Created):**
```json
{
   "success": true,
   "data": {
      "id": 1,
      "monto": 50.00,
      "metodo": "TRANSFERENCIA",
      "estado": "VERIFICACION",
      "numeroRecibo": null
   }
}
```
