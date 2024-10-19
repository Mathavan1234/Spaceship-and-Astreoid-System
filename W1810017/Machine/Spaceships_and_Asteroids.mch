/* Spaceships and Asteroids
 * Author: Maddy
 * Creation date: 11/20/2023
 */
MACHINE
    Spaceships_and_Asteroids
    
SETS
   // set ALERTS which holds all the possible alerts that the system can output throughout the game 
   ALERTS = { MOVED_UP, MOVED_DOWN, MOVED_LEFT, MOVED_RIGHT, WARPDRIVED, ASTEROID_COLLISION, OUT_OF_BOUNDS, INSUFFICIENT_POWER, DOCKED, NOT_DOCKED, GAME_WON, GAME_NOT_OVER, GAME_LOST }
       
CONSTANTS
    
    normal_move,   // holds the power consumption for a normal move (Directions - Up, Down, Forward, Backward )
    warpdrive,     // holds the power consumption for a warp-drive
    asteroid_hit,  // holds the amount of power loss when the spaceship crashes into an asteroid
    GRID_X,        // holds the x axis values   
    GRID_Y,        // holds the y axis values  
    ASTEROIDS,     // holds the values of asteroid location/co-ordinates in the grid
    starbase,      // holds the values of star-base location/co-ordinates in the grid
    homebase       // holds the initial value of home-base location/co-ordinates in the grid
    
PROPERTIES
    
    normal_move : NAT & normal_move = 5 &
    warpdrive : NAT & warpdrive = 20 &
    asteroid_hit : NAT & asteroid_hit = 10 &
    GRID_X <: NAT1 & GRID_X = 1..12 &
    GRID_Y <: NAT1 & GRID_Y = 1..7 &
    ASTEROIDS : GRID_X <-> GRID_Y & ASTEROIDS = { (3 |-> 2), (3 |-> 5), (5 |-> 4), (6 |-> 7), (7 |-> 1), (7 |-> 5), (7 |-> 7), (8 |-> 3), (10 |-> 6), (11 |-> 2), (12 |-> 5) } &
    starbase = (6 |-> 4) &
    homebase = (1 |-> 1)
          
VARIABLES
    
    spaceship_x,     // holds the current x position of the spaceship
    spaceship_y,     // holds the current y position of the spaceship
    spaceship_route, // holds the spaceship route from the home base to its current location/co-ordinate
    power_consumption,           // holds the spaceship's power consumption in a single game played
    collisions       // holds the collision number the spaceship had in a single game played
   
INVARIANT
    
    spaceship_x : GRID_X &                   // since x value can be only in the range from 1..12
    spaceship_y : GRID_Y &                   // since y value can be only in the range from 1..7
    spaceship_route : seq(GRID_X * GRID_Y) & // since spaceship route is a sequence that consists of map-lets of x and y
    power_consumption : INTEGER  &           // since value of power can go less than 0 (power < 0)                         
    collisions : NAT                         // since the collisions can be 0, it's declared as NAT and not as NAT 1 (there can be no collisions/asteroid hits in a single game)
    
INITIALISATION
    
    spaceship_x, spaceship_y, spaceship_route, power_consumption, collisions := 1, 1, [(homebase)], 0, 0
    
OPERATIONS
    
    // Start/Re-Start the game
    NewGame(power) = 
    PRE
       // power is a member of natural number starting from 1 and minimum power needed to reach the star base is 40 (since there is 8 squares need to be moved 8 * 5 = 40)
       power : NAT1 & power >= 40
    THEN
       spaceship_x, spaceship_y, spaceship_route, power_consumption, collisions := 1, 1, [(homebase)], power, 0
    END;
  
    // Move Up Operation -- Inquiry Operation
    message <-- MoveUp =
    BEGIN
        // checks whether already the spaceship is in the star base
        IF spaceship_x |-> spaceship_y = starbase
        THEN
            // show the necessary alert if it's in the star base
            message := GAME_WON
        ELSE 
            IF 
                // check whether there is an enough power consumption to make a normal move further
                power_consumption >= normal_move
            THEN 
                IF 
                    // check whether the new position is within the boundary of the grid
                    succ(spaceship_y) : GRID_Y
                THEN 
                    IF
                       // check whether the moved up square position is not an asteroid position
                       spaceship_x |-> succ(spaceship_y) /: ASTEROIDS
                    THEN
                       // if spaceship is not collided with asteroid, add current position to spaceship route,update the y position, update power consumption and return status alert message 
                       spaceship_route, spaceship_y, power_consumption, message := (spaceship_route <- (spaceship_x, succ(spaceship_y))), succ(spaceship_y), (power_consumption - normal_move), MOVED_UP
                    ELSE
                       // if spaceship is collided with asteroid, increment the collision by 1, reduce the power consumption by 10 and return status alert message
                       collisions, power_consumption, message := (collisions + 1), (power_consumption - asteroid_hit), ASTEROID_COLLISION
                    END
                ELSE
                    // return alert if it's out of bounds
                    message := OUT_OF_BOUNDS
                END
            ELSE
               // return alert if there is no enough power consumption
               message := INSUFFICIENT_POWER
            END
        END    
    END;
    
    // Move Down Operation -- Inquiry Operation
    message <-- MoveDown =
    BEGIN
        // checks whether already the spaceship is in the star base
        IF spaceship_x |-> spaceship_y = starbase
        THEN
            // show the necessary alert if it's in the star base
            message := GAME_WON
        ELSE 
            IF 
                // check whether there is an enough power consumption to make a normal move further
                power_consumption >= normal_move
            THEN 
                IF 
                    // check whether the new position is within the boundary of the grid
                    pred(spaceship_y) : GRID_Y
                THEN 
                    IF
                       // check whether the moved down square position is not an asteroid position
                       spaceship_x |-> pred(spaceship_y) /: ASTEROIDS
                    THEN
                       // if spaceship is not collided with asteroid, add current position to spaceship route,update the y position, update power consumption and return status alert message 
                       spaceship_route, spaceship_y, power_consumption, message := (spaceship_route <- (spaceship_x, pred(spaceship_y))), pred(spaceship_y), (power_consumption - normal_move), MOVED_DOWN
                    ELSE
                       // if spaceship is collided with asteroid, increment the collision by 1, reduce the power consumption by 10 and return status alert message
                       collisions, power_consumption, message := (collisions + 1), (power_consumption - asteroid_hit), ASTEROID_COLLISION
                    END
                ELSE
                    // return alert if it's out of bounds
                    message := OUT_OF_BOUNDS
                END
            ELSE
               // return alert if there is no enough power consumption
               message := INSUFFICIENT_POWER
            END
        END    
    END;
    
    // Move Left Operation -- Inquiry Operation ( Forward Movement)
    message <-- MoveLeft =
    BEGIN
        // checks whether already the spaceship is in the star base
        IF spaceship_x |-> spaceship_y = starbase
        THEN
            // show the necessary alert if it's in the star base
            message := GAME_WON
        ELSE 
            IF 
                // check whether there is an enough power consumption to make a normal move further
                power_consumption >= normal_move
            THEN 
                IF 
                    // check whether the new position is within the boundary of the grid
                    succ(spaceship_x) : GRID_X
                THEN 
                    IF
                       // check whether the moved left square position is not an asteroid position
                       succ(spaceship_x) |-> spaceship_y /: ASTEROIDS
                    THEN
                       // if spaceship is not collided with asteroid, add current position to spaceship route,update the x position, update power consumption and return status alert message 
                       spaceship_route, spaceship_x, power_consumption, message := (spaceship_route <- (succ(spaceship_x), spaceship_y)), succ(spaceship_x), (power_consumption - normal_move), MOVED_LEFT                                                  
                    ELSE
                       // if spaceship is collided with asteroid, increment the collision by 1, reduce the power consumption by 10 and return status alert message
                       collisions, power_consumption, message := (collisions + 1), (power_consumption - asteroid_hit), ASTEROID_COLLISION
                    END
                ELSE
                    // return alert if it's out of bounds
                    message := OUT_OF_BOUNDS
                END
            ELSE
               // return alert if there is no enough power consumption
               message := INSUFFICIENT_POWER
            END
        END    
    END;
    
    // Move Right Operation -- Inquiry Operation ( Backward Movement)
    message <-- MoveRight =
    BEGIN
        // checks whether already the spaceship is in the star base
        IF spaceship_x |-> spaceship_y = starbase
        THEN
            // show the necessary alert if it's in the star base
            message := GAME_WON
        ELSE 
            IF 
                // check whether there is an enough power consumption to make a normal move further
                power_consumption >= normal_move
            THEN 
                IF 
                    // check whether the new position is within the boundary of the grid
                    pred(spaceship_x) : GRID_X
                THEN 
                    IF
                       // check whether the moved right square position is not an asteroid position
                       pred(spaceship_x) |-> spaceship_y /: ASTEROIDS
                    THEN
                       // if spaceship is not collided with asteroid, add current position to spaceship route,update the x position, update power consumption and return status alert message 
                       spaceship_route, spaceship_x, power_consumption, message := (spaceship_route <- (pred(spaceship_x), spaceship_y)), pred(spaceship_x), (power_consumption - normal_move), MOVED_RIGHT                                                  
                    ELSE
                       // if spaceship is collided with asteroid, increment the collision by 1, reduce the power consumption by 10 and return status alert message
                       collisions, power_consumption, message := (collisions + 1), (power_consumption - asteroid_hit), ASTEROID_COLLISION
                    END
                ELSE
                    // return alert if it's out of bounds
                    message := OUT_OF_BOUNDS
                END
            ELSE
               // return alert if there is no enough power consumption
               message := INSUFFICIENT_POWER
            END
        END    
    END;
    
    // Engage in a warp-drive (Warp-Drive Spaceship Movement)
    message <-- WarpDrive (x_position, y_position) =
    PRE
        // check whether the parameters are natural numbers starting from 1 and they are not the coordinates of the spaceship's current location
        x_position : NAT1 & y_position : NAT1 & (x_position |-> y_position) /= (spaceship_x |-> spaceship_y)     
    THEN
        IF
            // checks whether already the spaceship is in the star base
            spaceship_x |-> spaceship_y = starbase
        THEN
            // show the necessary alert if it's in the star base
            message := GAME_WON
        ELSE
            IF
                // check whether there is an enough power consumption to make a warp drive
                power_consumption >= warpdrive
            THEN            
                IF
                    // check whether the new position in within the boundary of the grid
                    x_position : GRID_X & y_position : GRID_Y
                THEN
                    IF
                        // check whether the moved square position is not an asteroid position
                        x_position |-> y_position /: ASTEROIDS
                    THEN
                         // if spaceship is not collided with asteroid, add current position to spaceship route,update the x,y position, update power consumption and return status alert message 
                        spaceship_route, spaceship_x, spaceship_y, power_consumption, message := spaceship_route <- (x_position, y_position), x_position, y_position, (power_consumption - warpdrive), WARPDRIVED                   
                    ELSE
                         // if spaceship is collided with asteroid, increment the collision by 1, reduce the power consumption by 10 and return status alert message
                       collisions, power_consumption, message := (collisions + 1), (power_consumption - asteroid_hit), ASTEROID_COLLISION
                    END
                ELSE
                    // show alert if out of bounds
                    message := OUT_OF_BOUNDS
                END                            
            ELSE 
                // show alert if not enough power
                message := INSUFFICIENT_POWER
            END 
        END
    END;
    
    
    // Display Mission Status
    current_location, power_remaining, number_of_collision <-- MissionStatus =
    BEGIN
        // output current location, the power left and the number of collisions
        current_location, power_remaining, number_of_collision := spaceship_x |-> spaceship_y, power_consumption, collisions
    END;
    
     // Display Mission Route of the Spaceship
    travelledPath <-- RegionsVisited =
    BEGIN
        // output the traveled path spaceship has visited
        travelledPath := spaceship_route
    END;
    
     // Current Location of the spaceship
    message <-- DockedAtStarBase  =
    BEGIN
        IF 
            // check if star base location is same as the spaceship's current location
            starbase = (spaceship_x |-> spaceship_y)
        THEN
            // docked if both locations are same
            message := DOCKED
        ELSE
            // not docked if locations are different
            message := NOT_DOCKED
        END
    END;
    
     // Display Status of the Game
    status <-- GameStatus  =
    BEGIN
        IF
            // check if star base location is same as the spaceship's current location
            starbase = (spaceship_x |-> spaceship_y) 
        THEN 
            // game won if locations are same
            status := GAME_WON
        ELSE
            IF 
                // check if there is at least a power to do a normal move (which consumes the least power of 5)
                power_consumption >= normal_move
            THEN
                // if there is enough power, the game is still ongoing
                status := GAME_NOT_OVER
            ELSE
                // if there is no power enough to do a move, the game is lost
                status := GAME_LOST
            END
        END
   END
END
