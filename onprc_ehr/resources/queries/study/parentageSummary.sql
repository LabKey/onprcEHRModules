SELECT
    p.Id,
    p.date,
    Case when p.parent is not null then p.parent
         when t.dam is not null then t.dam
         when t2.sire is not null then t2.sire
        end as parent,
    case when p.parent is not null then  p.relationship
         when t.dam is not null then 'dam'
         when t2.sire is not null then 'sire'
        end as relationship,
    case when p.parent is not null then p.method
         when t.dam is not null then 'observed'
         when t2.sire is not null then 'observed'
        end as method



from study.parentage p


         LEFT JOIN

     ( select
           b.Id,
           b.date,
           b.dam,
           'Dam' as relationship,
           'Observed' as method


       from study.birth b
       where  b.dam is not null and b.qcstate.publicdata = true


     )t on (t.Id = p.Id)

         LEFT JOIN

     (  SELECT
            a.Id,
            a.date,
            a.sire,
            'Sire' as relationship,
            'Observed' as method

        FROM study.birth a
        where  a.sire is not null and a.qcstate.publicdata = true


     )t2 on (t2.Id =p.Id)

WHERE p.qcstate.publicdata = true and p.enddateCoalesced <= now()


