#!/bin/bash
# Set the PostgreSQL command and database information
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Ask the user to input their username
echo "Enter your username:"
read USERNAME

# Retrieve the user_id from the database based on the provided username
USER_ID=$($PSQL "SELECT user_id from usernames WHERE username='$USERNAME'")

# Check if the user is new or returning
if [[ -z $USER_ID ]]; then
    # Create a new username and display a welcome message
    CREATE_USERNAME=$($PSQL "INSERT INTO usernames(username) VALUES('$USERNAME')")
    echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
else
    # Retrieve the user's games played and best game information
    GAMES_PLAYED=$($PSQL "SELECT COUNT(game_id) FROM games WHERE user_id=$USER_ID;")
    BEST_GAME=$($PSQL "SELECT MIN(number_of_guesses) FROM games WHERE user_id=$USER_ID;")
    echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Generate a random number between 1 and 1000 for the secret number
SECRET_NUMBER=$((RANDOM % 1000 + 1))
NUMBER_OF_GUESSES=0

echo -e "\nGuess the secret number between 1 and 1000:"

# Start the guessing game loop
while true; do
    read GUESS_NUMBER

    # Check if the input is a valid integer
    if ! [[ $GUESS_NUMBER =~ ^[0-9]+$ ]]; then
        echo "That is not an integer, guess again:"
        continue
    fi

    NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES + 1))

    # Compare the guess with the secret number
    if [[ $GUESS_NUMBER -eq $SECRET_NUMBER ]]; then
        # Insert game information into the database
        USER_ID=$($PSQL "SELECT user_id from usernames WHERE username='$USERNAME'")
        GAME=$($PSQL "INSERT INTO games(user_id, number_of_guesses) VALUES($USER_ID, $NUMBER_OF_GUESSES)")
        echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!."
        break
    elif [[ $GUESS_NUMBER -lt $SECRET_NUMBER ]]; then
        echo "It's higher than that, guess again:"
    else
        echo "It's lower than that, guess again:"
    fi
done
