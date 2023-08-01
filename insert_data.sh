#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "truncate games, teams cascade")

cat games.csv | while IFS="," read Year Round Winner Opponent WinGoals OppGoals
do
  if [[ $Year != 'year' ]]
  then
    TEAM_CHECK=$($PSQL "select count(*) from teams where name='$Winner'")
    OPP_CHECK=$($PSQL "select count(*) from teams where name='$Opponent'")
    if [[ $TEAM_CHECK == 0 ]]
    then
      INSERT_DISTINCT_TEAMS=$($PSQL "insert into teams(name) values('$Winner')")
    fi
    if [[ $OPP_CHECK == 0 ]]
    then
    # POPULATE TEAMS TABLE FIRST
      INSERT_OPPONENTS=$($PSQL "insert into teams(name) values('$Opponent')")
    fi
  fi
done
cat games.csv | while IFS="," read Year Round Winner Opponent WinGoals OppGoals
do
  if [[ $Year != 'year' ]]
  then
    WIN_ID=$($PSQL "select team_id from teams where name='$Winner'")
    OPP_ID=$($PSQL "select team_id from teams where name='$Opponent'")
    INSERT_GAME=$($PSQL "insert into games (year, round, winner_id, opponent_id, winner_goals,opponent_goals) values ($Year, '$Round', $WIN_ID, $OPP_ID, $WinGoals, $OppGoals)")
    echo $Year, $Round, $WIN_ID, $OPP_ID, $WinGoals, $OppGoals
  fi
done