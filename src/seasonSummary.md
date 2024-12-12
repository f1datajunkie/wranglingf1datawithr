
# Season Summary

require(RSQLite)

con_ergastdb = dbConnect(drv='SQLite', dbname='./ergastdb13.sqlite')
kdb=function(q){ kable(dbGetQuery(con_ergastdb,q)) }

dbGetQuery(con_ergastdb, 'CREATE TEMPORARY VIEW drivers2013 AS SELECT * FROM drivers WHERE driverId IN (SELECT DISTINCT ds.driverId from driverStandings ds JOIN races r WHERE r.year=2013 AND r.raceId=ds.raceId )')

dbGetQuery(con_ergastdb, 'CREATE TEMPORARY VIEW constructors2013 AS SELECT * FROM constructors WHERE constructorId IN (SELECT DISTINCT cs.constructorId from constructorStandings cs JOIN races r WHERE r.year=2013 AND r.raceId=cs.raceId )')

dbGetQuery(con_ergastdb, 'SELECT * from drivers2013')
dbGetQuery(con_ergastdb, 'SELECT * from constructors2013')
