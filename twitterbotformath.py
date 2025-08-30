it would be fun to tweet random maths problems and physics equations but need a friend to set it up


# auto_tweeter.py

import tweepy
import time
import random

# --- IMPORTANT: Replace with your actual credentials ---
# You can get these from the X.com (Twitter) Developer Platform
# Make sure to keep these credentials secure and do not share them.
# The `bearer_token` is for authentication.
# The `consumer_key` and `consumer_secret` are for the app.
# The `access_token` and `access_token_secret` are for the user.
bearer_token = "YOUR_BEARER_TOKEN"
consumer_key = "YOUR_API_KEY"
consumer_secret = "YOUR_API_SECRET"
access_token = "YOUR_ACCESS_TOKEN"
access_token_secret = "YOUR_ACCESS_TOKEN_SECRET"

# List of messages to tweet. The script will pick one at random.
tweet_messages = [
    "Hello, world! This is an automated tweet.",
    "Python is a great tool for automating tasks. #Python",
    "Tweeting is easy with the X.com API!",
    "I'm a bot, but I'm learning! What should I tweet next?",
    f"The current time is {time.strftime('%H:%M:%S')}.",
    "Another hour, another automated message.",
]

# --- Initialize the API client ---
# The client object handles authentication and API requests.
client = tweepy.Client(
    bearer_token,
    consumer_key,
    consumer_secret,
    access_token,
    access_token_secret
)

def tweet_message(message):
    """
    Posts a single tweet to the X.com account.
    """
    try:
        response = client.create_tweet(text=message)
        print(f"Successfully tweeted: '{message}'")
        print(f"Tweet ID: {response.data['id']}")
    except tweepy.TweepyException as e:
        print(f"An error occurred while tweeting: {e}")

def main():
    """
    The main function that runs the tweeting loop.
    It posts a random message every hour.
    """
    print("Starting the Twitter automation script.")
    while True:
        # Select a random message from the list
        message_to_tweet = random.choice(tweet_messages)
        
        # Ensure the message is formatted with the current time if it's the specific template
        if message_to_tweet.startswith("The current time is"):
            message_to_tweet = f"The current time is {time.strftime('%H:%M:%S')}. #Bot"
            
        tweet_message(message_to_tweet)
        
        # Wait for 1 hour (3600 seconds) before the next tweet
        print("Waiting for 1 hour...")
        time.sleep(3600)

# Run the main function
if __name__ == "__main__":
    main()
