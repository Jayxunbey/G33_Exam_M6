-- Muxammadov Jayxunbek G33;
-- Design link:  https://drawsql.app/teams/jayxunbeys-team/diagrams/hospital-management-system



---------------------------------------------------------------------------
-- Code of Query:

CREATE TABLE "patient"(
                          "id" bigserial NOT NULL,
                          "person_id" BIGINT NOT NULL,
                          "disease_type" VARCHAR(255) NOT NULL,
                          "weight" INTEGER NULL,
                          "height" INTEGER NULL,
                          "active" BOOLEAN NOT NULL
);

ALTER TABLE
    "patient" ADD PRIMARY KEY("id");
ALTER TABLE
    "patient" ADD CONSTRAINT "patient_person_id_unique" UNIQUE("person_id");
CREATE TABLE "person"(
                         "id" bigserial NOT NULL,
                         "first_name" VARCHAR(255) NOT NULL,
                         "last_name" VARCHAR(255) NOT NULL,
                         "birth_day" DATE NOT NULL,
                         "address" VARCHAR(255) NOT NULL
);
ALTER TABLE
    "person" ADD PRIMARY KEY("id");
CREATE TABLE "appointment_scheduling"(
                                         "id" bigserial NOT NULL,
                                         "patient_id" BIGINT NOT NULL,
                                         "medical_staff_id" BIGINT NOT NULL,
                                         "meeting_date" DATE NOT NULL,
                                         "active" BOOLEAN NOT NULL
);
ALTER TABLE
    "appointment_scheduling" ADD PRIMARY KEY("id");
CREATE TABLE "medical_staff"(
                                "id" bigserial NOT NULL,
                                "person_id" BIGINT NOT NULL,
                                "skill" VARCHAR(255) NOT NULL,
                                "exprience_year" INTEGER NOT NULL,
                                "active" BOOLEAN NOT NULL
);
ALTER TABLE
    "medical_staff" ADD PRIMARY KEY("id");
ALTER TABLE
    "medical_staff" ADD CONSTRAINT "medical_staff_person_id_unique" UNIQUE("person_id");
ALTER TABLE
    "appointment_scheduling" ADD CONSTRAINT "appointment_scheduling_medical_staff_id_foreign" FOREIGN KEY("medical_staff_id") REFERENCES "medical_staff"("id");
ALTER TABLE
    "appointment_scheduling" ADD CONSTRAINT "appointment_scheduling_patient_id_foreign" FOREIGN KEY("patient_id") REFERENCES "patient"("id");
ALTER TABLE
    "patient" ADD CONSTRAINT "patient_person_id_foreign" FOREIGN KEY("person_id") REFERENCES "person"("id");
ALTER TABLE
    "medical_staff" ADD CONSTRAINT "medical_staff_person_id_foreign" FOREIGN KEY("person_id") REFERENCES "person"("id");


---------------------------------------------------------------------------
-- Code of inserting data


insert into person (first_name, last_name, birth_day, address)
values ('Jayxunbek', 'Muxammadov', '2003.04.03','Uzbekistan'),
       ('Nosirbek', 'Muxammadsharipov', '2003.12.31','Uzbekistan'),
       ('Javohir', 'Sadullayev', '2002.07.05','Uzbekistan'),
       ('Sarvar', 'Aminov', '2003.10.26','Uzbekistan'),
       ('Umid', 'Qurbonboyev', '2001.06.16','Uzbekistan'),
       ('Sarvar', 'Hasanov', '2003.01.29','Uzbekistan'),
       ('Azamat', 'Saidov', '1999.03.18','Uzbekistan');

select * from person;


insert into patient(person_id, disease_type, weight, height, active)
values (4,'Gripp',80,175,true),
       (6,'Shamollash',75,168,true),
       (7,'Angina',82,185,false),
       (2,'Bosh ogrigi',90,180,true);

select * from patient;

insert into medical_staff(person_id, skill, exprience_year, active)
values (1,'Bosh vraj',10, true),
       (3,'Lor',5, false),
       (5,'Kojenni',3, true);

select * from medical_staff;
    
   

---------------------------------------------------------------------------
-- Code of Function and Procedures query

create or replace function find_patient_by_name(
        p_name varchar(255)
) returns table
    (
        id bigint,
        person_id bigint,
        first_name varchar,
        last_name varchar,
        disease_type varchar(255),
        weight int,
        height int,
        active boolean
    )
language plpgsql
as
$$
    BEGIN
        return query
            select patient.id,
                   person.id,
                   person.first_name,
                   person.last_name,
                   patient.disease_type,
                   patient.weight,
                   patient.height,
                   patient.active
            from patient
            inner join person on patient.person_id = person.id
            where patient.active = true and person.first_name  ILIKE '%' || p_name || '%';
    end;
$$;

select * from find_patient_by_name('r');



create or replace procedure appointment_creation_procedure(
            param_patient_id bigint,
            param_medical_staff_id bigint,
            param_date_of_meeting date
) language plpgsql
as
$$
    begin
        insert into appointment_scheduling(patient_id, medical_staff_id, meeting_date, active)
        values (param_patient_id, param_medical_staff_id, param_date_of_meeting, true);
    end;
$$;


call appointment_creation_procedure(1,3,'2024.01.15');
call appointment_creation_procedure(3,3,'2024.01.16');
call appointment_creation_procedure(4,2,'2024.01.17');
call appointment_creation_procedure(2,1,'2024.01.18');
call appointment_creation_procedure(3,3,'2023.12.15');
call appointment_creation_procedure(3,3,'2024.01.16');
call appointment_creation_procedure(4,1,'2024.01.17');
call appointment_creation_procedure(4,3,'2024.01.16');
call appointment_creation_procedure(1,2,'2024.01.18');
call appointment_creation_procedure(2,1,'2024.01.16');
call appointment_creation_procedure(3,3,'2024.01.16');
call appointment_creation_procedure(4,1,'2023.12.16');
call appointment_creation_procedure(1,2,'2023.12.16');



create view meetings_of_today
    as
        select *
        from appointment_scheduling a
        where extract(day from a.meeting_date) = extract(day from now());


drop materialized view count_of_meetings_of_last_month;

create materialized view  count_of_meetings_of_last_month
    as
        select
        from appointment_scheduling a
        inner join patient pat on a.patient_id = pat.id
        inner join person per on pat.person_id = per.id
        where
            extract(day from now()-a.meeting_date) > 30;


refresh materialized view count_of_meetings_of_last_month;
