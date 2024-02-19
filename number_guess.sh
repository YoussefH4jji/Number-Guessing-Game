#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\nEnter your username:"
read USERNAME

# get username data
USERNAME_RESULT=$($PSQL "SELECT name FROM users WHERE name='$USERNAME'")
# get user id
USER_ID_RESULT=$($PSQL "SELECT user_id FROM users WHERE name='$USERNAME'")

if [[ -z $USERNAME_RESULT ]]
  then
    echo -e "\nWelcome, $USERNAME! It looks like this is your first time here.\n"
    INSERT_USERNAME_RESULT=$($PSQL "INSERT INTO users(name) VALUES ('$USERNAME')")
    
  else
    
    GAMES_PLAYED=$($PSQL "SELECT COUNT(game_id) FROM games LEFT JOIN users USING(user_id) WHERE name='$USERNAME'")
    BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games LEFT JOIN users USING(user_id) WHERE name='$USERNAME'")

    echo Welcome back, $USERNAME\! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.
fi

SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

GUESS_COUNT=0

echo "Guess the secret number between 1 and 1000:"
read USER_GUESS


until [[ $USER_GUESS == $SECRET_NUMBER ]]
do
  
  if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
    then
      echo -e "\nThat is not an integer, guess again:"
      read USER_GUESS
      # update guess count
      ((GUESS_COUNT++))
    
    # if its a valid guess
    else
      # check inequalities and give hint
      if [[ $USER_GUESS < $SECRET_NUMBER ]]
        then
          echo "It's higher than that, guess again:"
          read USER_GUESS
          # update guess count
          ((GUESS_COUNT++))
        else 
          echo "It's lower than that, guess again:"
          read USER_GUESS
          #update guess count
          ((GUESS_COUNT++))
      fi  
  fi

done

((GUESS_COUNT++))

# get user id
USER_ID_RESULT=$($PSQL "SELECT user_id FROM users WHERE name='$USERNAME'")
INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, guesses) VALUES ($USER_ID_RESULT, $GUESS_COUNT)")

echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"
