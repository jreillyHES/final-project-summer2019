"# final-project-summer2019" 

Super Mario Bros.

1. Add actual levels to the game. Display the current level in the upper right corner and display a message when the level is completed.  Give a scoring bonus times the level number when a level is cleared. 


2. When loading a level, have the flagpole (but not the flag!) generate on the last block which should be solid ground so the flagpole does not float in mid-air. Also, randomly generate the key and lock block when loading the level. The player must first obtain the key (onConsume) before unlocking the lock block (onConsume). When the lock block is opened, the flag will appear at the top of the flagpole. The player completes the level by capturing the flag (onConsume).


3. Add three lives to the game, displaying the lives left in the upper left corner. If a player dies with lives left, drop them back into the level at the same location but making sure they are always above solid ground. Move the player forward in the level if necessary.

4. Add a random chance to generate a star for an extra life when generating a gem only if the player has less than 3 lives left. Also, award an extra life if the player achieves a certain score. This award can be received even if the player already has 3 lives. In this case only, a player can have a maximum of 4 lives. 
. Add a random chance to generate a mushroom for invincibility when generating a gem. Invincibility should only last for a set period a time. A player that has invincibility cannot be killed by enemies or fall below ground level in gaps. 
