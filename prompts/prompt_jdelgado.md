1. En base al @docs/erd.md que es el diagrama entidad relación, revísalo y aplica las reglas de la normalización de base de datos y actualízalo.

2. Valida que esté normalizado como Forma Normal de Boyce-Codd (FNBC).

3. La tabla postal_code cámbiala por address y agrega postal_code como un campo dentro de esta tabla.

4. Actualiza el schema de Prisma.

5. Valida que address este bien implementada que este referenciada de manera correcta

5. Crea el código SQL de la generación de la base de datos llamada LTIdb de acuerdo al diagrama entidad relación y genera los índices de acuerdo a mejorar el rendimiento de la base de datos.

6. Agrega el MCP para conexión a postgres.

7. Usando el MCP de postgres, crea la base de datos de LTIdb.

8. Lista las tablas creadas y valida que no falte ninguna, así como los índices.



