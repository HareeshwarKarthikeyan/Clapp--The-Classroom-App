
insert  into \"timetable\" values('abcd',1,1,'001math')

insert into "subject" values('001math','maths','abcd');

select subject_id, subject_name from \"subject\" where class_id='$classId';

select hour,subject_id from \"timetable\" where class_id='$classId' and day;