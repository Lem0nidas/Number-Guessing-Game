#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=guessing_game -t --no-align -c"

echo "Enter your username:"
read USERNAME

PLAYER=$($PSQL "SELECT username, games_played, guesses FROM stats WHERE username='$USERNAME'")
if [[ -z $PLAYER ]]
then
  INSERT_PLAYER=$($PSQL "INSERT INTO stats (username) VALUES ('$USERNAME')")
  NEW_PLAYER='True'

  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  echo "$PLAYER" | while IFS='|' read NAME GAMES RECORD
  do
    echo "Welcome back, $NAME! You have played $GAMES games, and your best game took $RECORD guesses."
  done
fi


TEMP=$[ $RANDOM % 1000 + 1 ]
COUNT=1

echo "Guess the secret number between 1 and 1000:"
read NUMBER_GUESSED


while [[ $NUMBER_GUESSED != $TEMP ]]
do
  COUNT=$[ $COUNT + 1 ]
  if [[ ! $NUMBER_GUESSED =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    read NUMBER_GUESSED
  elif [[ $NUMBER_GUESSED > $TEMP ]]
  then
    echo "It's lower than that, guess again:"
    read NUMBER_GUESSED
  else
    echo "It's higher than that, guess again:"
    read NUMBER_GUESSED
  fi
done


echo "You guessed it in $COUNT tries. The secret number was $NUMBER_GUESSED. Nice job!"


echo "$PLAYER" | while IFS='|' read NAME GAMES RECORD
do
  GAMES=$[ $GAMES + 1 ]
  if [[ ($NEW_PLAYER == 'True') || ($COUNT < $RECORD)]]
  then
    UPDATE_PLAYER=$($PSQL "UPDATE stats SET games_played = $GAMES WHERE username='$USERNAME'")
    UPDATE_PLAYER=$($PSQL "UPDATE stats SET guesses = $COUNT WHERE username='$USERNAME'")
  else 
    UPDATE_PLAYER=$($PSQL "UPDATE stats SET games_played = $GAMES WHERE username='$USERNAME'")
  fi
done