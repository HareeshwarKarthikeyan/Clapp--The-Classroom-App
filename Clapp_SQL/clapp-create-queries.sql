

CREATE TABLE "student" (
  "student_name" varchar(30),
  "user_id" varchar(60)
);

CREATE INDEX "Key" ON  "student" ("student_name");

CREATE INDEX "Fk" ON  "student" ("user_id");

CREATE TABLE "user" (
  "user_id" varchar(60),
  "contact" numeric,
  "profile" varchar(10),
  "email" varchar(30),
  PRIMARY KEY ("user_id")
);

CREATE INDEX "Key1" ON  "user" ("contact", "profile", "email");

CREATE TABLE "member" (
  "class_id" varchar(60),
  "user_id" varchar(60),
  "admin" int
);

CREATE INDEX "Fk1" ON  "member" ("class_id");

CREATE INDEX "PK,Fk2" ON  "member" ("user_id");

CREATE INDEX "Key2" ON  "member" ("admin");

CREATE TABLE "teacher" (
  "teacher_name" varchar(30),
  "user_id" varchar(60)
);

CREATE INDEX "Fk3" ON  "teacher" ("user_id");

CREATE INDEX "Key3" ON  "teacher" ("teacher_name");

CREATE TABLE "class" (
  "class_id" varchar(60),
  "password" varchar(60),
  "class_name" varchar(30),
  PRIMARY KEY ("class_id")
);

CREATE INDEX "Key4" ON  "class" ("password", "class_name");

