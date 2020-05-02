CREATE TABLE "contents" (
  "content_id" varchar(60),
  PRIMARY KEY ("content_id")
);

CREATE TABLE "student" (
  "student_name" varchar(30),
  "user_id" varchar(60)
);

CREATE INDEX "Key" ON  "student" ("student_name");

CREATE INDEX "PK,FK" ON  "student" ("user_id");

CREATE TABLE "user" (
  "user_id" varchar(60),
  "contact" numeric,
  "profile" varchar(10),
  "email" varchar(30),
  PRIMARY KEY ("user_id")
);

CREATE INDEX "Key" ON  "user" ("contact", "profile", "email");

CREATE TABLE "member" (
  "class_id" varchar(60),
  "user_id" varchar(60),
  "admin" int
);

CREATE INDEX "FK" ON  "member" ("class_id");

CREATE INDEX "PK,FK" ON  "member" ("user_id");

CREATE INDEX "Key" ON  "member" ("admin");

CREATE TABLE "teacher" (
  "teacher_name" varchar(30),
  "user_id" varchar(60)
);

CREATE INDEX "Key" ON  "teacher" ("teacher_name");

CREATE INDEX "PK,FK" ON  "teacher" ("user_id");

CREATE TABLE "class" (
  "class_id" varchar(60),
  "password" varchar(60),
  "class_name" varchar(30),
  PRIMARY KEY ("class_id")
);

CREATE INDEX "Key" ON  "class" ("password", "class_name");

CREATE TABLE "timetable" (
  "class_id" varchar(60),
  "day" int,
  "hour" int,
  "subject_id" varchar(60),
  PRIMARY KEY ("class_id","day", "hour")
);

CREATE INDEX "PK,FK" ON  "timetable" ("class_id");

CREATE INDEX "FK" ON  "timetable" ("subject_id");

CREATE TABLE "document" (
  "document_id" varchar(60),
  "subject_id" varchar(60),
  "download_title" varchar(20),
  "download_URL" varchar(200),
  PRIMARY KEY ("document_id")
);

CREATE INDEX "FK" ON  "document" ("subject_id");

CREATE INDEX "Key" ON  "document" ("download_title", "download_URL");

CREATE TABLE "subject" (
  "subject_id" varchar(60),
  "subject_name" varchar(60),
  "class_id" varchar(60),
  PRIMARY KEY ("subject_id","class_id")
);

CREATE INDEX "Key" ON  "subject" ("subject_name");

CREATE INDEX "PK,FK" ON  "subject" ("class_id");


