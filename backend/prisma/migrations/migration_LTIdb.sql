-- ============================================================
-- TABLAS DE CATÁLOGO
-- ============================================================

CREATE TABLE role (
    id   SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE employment_type (
    id   SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE interview_result (
    id   SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

-- ============================================================
-- EMPRESA Y EMPLEADOS
-- ============================================================

CREATE TABLE company (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    description TEXT
);

CREATE TABLE employee (
    id         SERIAL  PRIMARY KEY,
    company_id INT          NOT NULL,
    role_id    INT          NOT NULL,
    name       VARCHAR(100) NOT NULL,
    email      VARCHAR(255) NOT NULL UNIQUE,
    is_active  BOOLEAN      NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_employee_company FOREIGN KEY (company_id) REFERENCES company(id),
    CONSTRAINT fk_employee_role    FOREIGN KEY (role_id)    REFERENCES role(id)
);

-- ============================================================
-- FLUJO DE ENTREVISTAS
-- ============================================================

CREATE TABLE interview_flow (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    description VARCHAR(255)
);

CREATE TABLE interview_type (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE interview_step (
    id                SERIAL PRIMARY KEY,
    interview_flow_id INT          NOT NULL,
    interview_type_id INT          NOT NULL,
    name              VARCHAR(100) NOT NULL,
    order_index       INT          NOT NULL,
    CONSTRAINT fk_step_flow        FOREIGN KEY (interview_flow_id) REFERENCES interview_flow(id),
    CONSTRAINT fk_step_type        FOREIGN KEY (interview_type_id) REFERENCES interview_type(id),
    CONSTRAINT uq_step_flow_order  UNIQUE (interview_flow_id, order_index)
);

-- ============================================================
-- POSICIONES / VACANTES
-- ============================================================

CREATE TABLE position (
    id                   SERIAL PRIMARY KEY,
    company_id           INT          NOT NULL,
    interview_flow_id    INT          NOT NULL,
    employment_type_id   INT          NOT NULL,
    title                VARCHAR(255) NOT NULL,
    summary              VARCHAR(500),
    job_description      TEXT,
    requirements         TEXT,
    responsibilities     TEXT,
    status               VARCHAR(50)  NOT NULL,
    is_visible           BOOLEAN      NOT NULL DEFAULT TRUE,
    location             VARCHAR(255),
    salary_min           NUMERIC(10,2),
    salary_max           NUMERIC(10,2),
    benefits             TEXT,
    application_deadline TIMESTAMP,
    CONSTRAINT fk_position_company        FOREIGN KEY (company_id)          REFERENCES company(id),
    CONSTRAINT fk_position_interview_flow FOREIGN KEY (interview_flow_id)   REFERENCES interview_flow(id),
    CONSTRAINT fk_position_employment     FOREIGN KEY (employment_type_id)  REFERENCES employment_type(id)
);

CREATE TABLE position_contact (
    id            SERIAL PRIMARY KEY,
    position_id   INT          NOT NULL,
    contact_name  VARCHAR(100) NOT NULL,
    contact_email VARCHAR(255) NOT NULL,
    contact_phone VARCHAR(20),
    CONSTRAINT fk_contact_position FOREIGN KEY (position_id) REFERENCES position(id)
);

-- ============================================================
-- CANDIDATOS
-- ============================================================

CREATE TABLE address (
    id          SERIAL PRIMARY KEY,
    street      VARCHAR(255),
    postal_code VARCHAR(20),
    city        VARCHAR(100) NOT NULL,
    state       VARCHAR(100) NOT NULL,
    country     VARCHAR(100) NOT NULL
);

CREATE TABLE candidate (
    id         SERIAL PRIMARY KEY,
    address_id INT,
    first_name VARCHAR(100) NOT NULL,
    last_name  VARCHAR(100) NOT NULL,
    email      VARCHAR(255) NOT NULL UNIQUE,
    phone      VARCHAR(20),
    CONSTRAINT fk_candidate_address FOREIGN KEY (address_id) REFERENCES address(id)
);

CREATE TABLE education (
    id           SERIAL PRIMARY KEY,
    candidate_id INT          NOT NULL,
    institution  VARCHAR(100) NOT NULL,
    title        VARCHAR(250) NOT NULL,
    start_date   TIMESTAMP    NOT NULL,
    end_date     TIMESTAMP,
    CONSTRAINT fk_education_candidate FOREIGN KEY (candidate_id) REFERENCES candidate(id)
);

CREATE TABLE work_experience (
    id           SERIAL PRIMARY KEY,
    candidate_id INT          NOT NULL,
    company      VARCHAR(100) NOT NULL,
    position     VARCHAR(100) NOT NULL,
    description  VARCHAR(200),
    start_date   TIMESTAMP    NOT NULL,
    end_date     TIMESTAMP,
    CONSTRAINT fk_work_experience_candidate FOREIGN KEY (candidate_id) REFERENCES candidate(id)
);

CREATE TABLE resume (
    id           SERIAL PRIMARY KEY,
    candidate_id INT          NOT NULL,
    file_path    VARCHAR(500) NOT NULL,
    file_type    VARCHAR(50)  NOT NULL,
    upload_date  TIMESTAMP    NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_resume_candidate FOREIGN KEY (candidate_id) REFERENCES candidate(id)
);

-- ============================================================
-- APLICACIONES Y ENTREVISTAS
-- ============================================================

CREATE TABLE application (
    id               SERIAL PRIMARY KEY,
    position_id      INT         NOT NULL,
    candidate_id     INT         NOT NULL,
    application_date TIMESTAMP   NOT NULL DEFAULT NOW(),
    status           VARCHAR(50) NOT NULL,
    notes            TEXT,
    CONSTRAINT fk_application_position            FOREIGN KEY (position_id)  REFERENCES position(id),
    CONSTRAINT fk_application_candidate           FOREIGN KEY (candidate_id) REFERENCES candidate(id),
    CONSTRAINT uq_application_position_candidate  UNIQUE (position_id, candidate_id)
);

CREATE TABLE interview (
    id                SERIAL PRIMARY KEY,
    application_id    INT  NOT NULL,
    interview_step_id INT  NOT NULL,
    employee_id       INT  NOT NULL,
    interview_date    TIMESTAMP NOT NULL,
    result_id         INT,
    score             INT,
    notes             TEXT,
    CONSTRAINT fk_interview_application FOREIGN KEY (application_id)   REFERENCES application(id),
    CONSTRAINT fk_interview_step        FOREIGN KEY (interview_step_id) REFERENCES interview_step(id),
    CONSTRAINT fk_interview_employee    FOREIGN KEY (employee_id)       REFERENCES employee(id),
    CONSTRAINT fk_interview_result      FOREIGN KEY (result_id)         REFERENCES interview_result(id),
    CONSTRAINT uq_interview_app_step    UNIQUE (application_id, interview_step_id)
);

-- ============================================================
-- ÍNDICES DE RENDIMIENTO
-- ============================================================

-- employee: búsquedas por empresa, rol y estado activo
CREATE INDEX idx_employee_company_id ON employee(company_id);
CREATE INDEX idx_employee_role_id    ON employee(role_id);
CREATE INDEX idx_employee_is_active  ON employee(is_active);

-- interview_step: JOINs por flujo y tipo
CREATE INDEX idx_interview_step_flow_id ON interview_step(interview_flow_id);
CREATE INDEX idx_interview_step_type_id ON interview_step(interview_type_id);

-- position: filtros más frecuentes en búsqueda de vacantes
CREATE INDEX idx_position_company_id          ON position(company_id);
CREATE INDEX idx_position_interview_flow_id   ON position(interview_flow_id);
CREATE INDEX idx_position_employment_type_id  ON position(employment_type_id);
CREATE INDEX idx_position_status              ON position(status);
CREATE INDEX idx_position_is_visible          ON position(is_visible);
CREATE INDEX idx_position_deadline            ON position(application_deadline);
CREATE INDEX idx_position_location            ON position(location);

-- position (compuestos): consultas combinadas habituales
CREATE INDEX idx_position_status_visible  ON position(status, is_visible);    -- vacantes abiertas y visibles
CREATE INDEX idx_position_company_status  ON position(company_id, status);    -- vacantes de empresa por estado

-- position_contact
CREATE INDEX idx_position_contact_position_id ON position_contact(position_id);

-- candidate: búsqueda por nombre y dirección
CREATE INDEX idx_candidate_address_id ON candidate(address_id);
CREATE INDEX idx_candidate_name       ON candidate(last_name, first_name);    -- búsqueda por apellido + nombre

-- education / work_experience / resume
CREATE INDEX idx_education_candidate_id       ON education(candidate_id);
CREATE INDEX idx_work_experience_candidate_id ON work_experience(candidate_id);
CREATE INDEX idx_resume_candidate_id          ON resume(candidate_id);

-- application: filtros por estado, fecha y candidato
CREATE INDEX idx_application_position_id       ON application(position_id);
CREATE INDEX idx_application_candidate_id      ON application(candidate_id);
CREATE INDEX idx_application_status            ON application(status);
CREATE INDEX idx_application_date              ON application(application_date);

-- application (compuesto): historial de un candidato filtrado por estado
CREATE INDEX idx_application_candidate_status ON application(candidate_id, status);

-- interview: JOINs y filtros por fecha y empleado
CREATE INDEX idx_interview_application_id  ON interview(application_id);
CREATE INDEX idx_interview_step_id         ON interview(interview_step_id);
CREATE INDEX idx_interview_employee_id     ON interview(employee_id);
CREATE INDEX idx_interview_result_id       ON interview(result_id);
CREATE INDEX idx_interview_date            ON interview(interview_date);

-- interview (compuesto): agenda de entrevistas de un empleado por fecha
CREATE INDEX idx_interview_employee_date ON interview(employee_id, interview_date);
