select * from json_table jt, json_table2 jt2 where jt.id = jt2.id;
select * from csv_table ct, csv_table2 ct2 where ct.id = ct2.id and ct.name = 'John';