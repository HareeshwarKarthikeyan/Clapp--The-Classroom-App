1.
SELECT "member"."class_id","class"."class_name"
FROM "member","class"
WHERE "member"."user_id"=1 and "member"."class_id" = "class"."class_id";

2. 
SELECT s."student_name"
FROM "member" m,"student" s
WHERE m."class_id"=92 AND m."user_id"=s."user_id";

3.
SELECT t."teacher_name"
FROM "member" m,"teacher" t
WHERE m."class_id"=92 AND m."user_id"=t."user_id";

4.
select admin
from member m
where m."class_id"=91 and m."user_id"=1;

5. 
--students
--admins
SELECT s.student_name,s.user_id FROM \"member\" m,\"student\" s WHERE m.class_id=92 AND m.admin=1 AND m.user_id=s.user_id;
--nonadmins
SELECT s.student_name,s.user_id
FROM MEMBER m,student s
WHERE m.class_id=92 AND m.admin=0 AND m.user_id=s.user_id;
--both admins and non admins
SELECT s.student_name,s.user_id FROM \"member\" m,\"student\" s WHERE m.class_id=92 AND m.user_id=s.user_id;
--faculty
SELECT t.teacher_name,t.user_id
FROM MEMBER m,teacher t
WHERE m.class_id=92 AND m.user_id=t.user_id;
--info of a given faculty 
SELECT t.teacher_name,u.contact,u.email
FROM "teacher" t, "user" u
WHERE u.user_id=2 AND t.user_id=u.user_id;
--info of a given member
SELECT s.student_name,u.contact,u.email FROM \"student\" s, \"user\" u WHERE u.user_id=3 AND s.user_id=u.user_id;




9.
select count(class_id)
from class;

10. 
select class_id from class where class_id=92;
-- if this returns null, then such a class does not exist

11.
SELECT password FROM "class" WHERE class_id=91;

14.
select count(subject_id)
from subject;

15.
select subject_id,subject_name
from subject;

16.
select count(document_id)
from document d,subject s
where s.subject_id=100 and s.subject_id=d.subject_id;

17.
SELECT d.download_title,d."download_URL"
FROM "document" d,"subject" s
WHERE s.subject_id=100 AND s.subject_id=d.subject_id;


18.
list



