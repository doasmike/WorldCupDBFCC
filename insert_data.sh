#! /bin/bash

if [[ $1 == "test" ]]; then
    PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
    PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "DROP TABLE teams CASCADE;")
echo $($PSQL "DROP TABLE games CASCADE;")

echo $($PSQL "CREATE TABLE teams(team_id SERIAL PRIMARY KEY NOT NULL, name VARCHAR UNIQUE NOT NULL);")
echo $($PSQL "CREATE TABLE games(game_id SERIAL PRIMARY KEY NOT NULL, year INT NOT NULL, round VARCHAR NOT NULL, winner_id INT NOT NULL, opponent_id INT NOT NULL, FOREIGN KEY (winner_id) REFERENCES teams(team_id), FOREIGN KEY (opponent_id) REFERENCES teams(team_id), winner_goals INT NOT NULL, opponent_goals INT NOT NULL);")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS; do
    if [[ $OPPONENT != opponent || $WINNER != winner ]]; then
        # get team_id
        OPPONENT_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
        # if not found
        if [[ -z $OPPONENT_TEAM_ID ]]; then
            # insert team
            INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES ('$OPPONENT')")
            if [[ $INSERT_TEAM_RESULT == 'INSERT 0 1' ]]; then
                echo 'Inserted into team, '$OPPONENT''
            fi
            # get new team_id
            OPPONENT_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
        fi
        # get team_id
        WINNER_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
        # if not found
        if [[ -z $WINNER_TEAM_ID ]]; then
            # insert team
            INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES ('$WINNER')")
            if [[ $INSERT_TEAM_RESULT == 'INSERT 0 1' ]]; then
                echo 'Inserted into team, '$WINNER''
            fi
            # get new team_id
            WINNER_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
        fi
        # get game_id
        GAME_ID=$($PSQL "SELECT game_id FROM games WHERE year = $YEAR AND round = '$ROUND' AND winner_id = $WINNER_TEAM_ID AND opponent_id = $OPPONENT_TEAM_ID;")
        # if not found
        if [[ -z $GAME_ID ]]; then
            # insert game
            INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($YEAR, '$ROUND', $WINNER_TEAM_ID, $OPPONENT_TEAM_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
            if [[ $INSERT_GAME_RESULT == 'INSERT 0 1' ]]; then
                echo 'Inserted into games, '$YEAR, $ROUND, $WINNER_TEAM_ID, $OPPONENT_TEAM_ID, $WINNER_GOALS, $OPPONENT_GOALS''
            fi
            # get new game_id
            GAME_ID=$($PSQL "SELECT game_id FROM games")
        fi
    fi

done
