/* Initial beliefs and rules */

// initially, I believe that there is some beer in the fridge
available(beer,fridge).

// my owner should not consume more than 10 beers a day :-)
limit(beer,5).

too_much(B) :-
   .date(YY,MM,DD) &
   .count(consumed(YY,MM,DD,_,_,_,B),QtdB) &
   limit(B,Limit) &
   QtdB > Limit.
   
actual(1).
mensaje(1,"chiste1").
mensaje(2,"chiste2").

/* Initial goals */

!bringBeer.

/* Plans */

+!geet : actual(Ord) & mensaje(Ord,M) <- .println(M);
	.send(myOwner,tell,new(Ord+1)).
	-!geet.

+new(NewOrd) : actual(Ord) <-
	.abolish(actual(Ord));
	.abolish(new(_));
	+actual(NewOrd);
	!geet.

+!bring(myOwner, beer) <-
	+asked(beer).
	
+!bringBeer : healthMsg(_) <- 
	.println("El Robot descansa porque Owner ha bebido mucho hoy.").
+!bringBeer : asked(beer) & not healthMsg(_) <- 
	.println("Owner me ha pedido una cerveza.");
	!go_at(myRobot,fridge);
	!take(fridge,beer);
	!go_at(myRobot,myOwner);
	!hasBeer(myOwner);
	.println("Ya he servido la cerveza y elimino la petición.");
	.abolish(asked(Beer));
	.wait(2000);
	!go_at(myRobot,trash);
	!throwBeer;
	!bringBeer.
+!bringBeer : not asked(beer) & not healthMsg(_) <- 
	.wait(2000);
	.println("Robot esperando la petición de Owner.");
	!bringBeer.

+!take(fridge, beer) : not too_much(beer) <-
	.println("El robot está cogiendo una cerveza.");
	!check(fridge, beer).
+!take(fridge,beer) : too_much(beer) & limit(beer, L) <-
	.concat("The Department of Health does not allow me to give you more than ", L," beers a day! I am very sorry about that!", M);
	-+healthMsg(M).
	
+!check(fridge, beer) : available(beer,fridge) <-
	open(fridge);
	get(beer);
	close(fridge).
+!check(fridge, beer) : not available(beer,fridge) <-
	!orderBeer(mySupermarket);
	!check(fridge, beer).
+!check(fridge, beer) <-
	!check(fridge, beer).

+!orderBeer(Supermarket) : not ordered(beer) <-
	.println("El robot realiza un pedido al supermercado.");
	.send(Supermarket, achieve, order(beer,3));
	+ordered(beer).
+!orderBeer(Supermarket).

+!hasBeer(myOwner) : not too_much(beer) <-
	hand_in(beer);
	.println("He preguntado si Owner ha cogido la cerveza.");
	?has(myOwner,beer);
	.println("Se que Owner tiene la cerveza.");
	// remember that another beer has been consumed
	.date(YY,MM,DD); .time(HH,NN,SS);
	+consumed(YY,MM,DD,HH,NN,SS,beer).
+!hasBeer(myOwner) : too_much(beer) & healthMsg(M) <- 
	//.abolish(msg(_));
	.send(myOwner,tell,msg(M)).

+!go_at(myRobot,P) : at(myRobot,P) <- true.
+!go_at(myRobot,P) : not at(myRobot,P)
  <- move_towards(P);
     !go_at(myRobot,P).
	 
+!throwBeer <- 
	.println("Tirando la botella vac?a");
	throw(beer).

// when the supermarket makes a delivery, try the 'has' goal again
+delivered(beer,_Qtd,_OrderId)[source(mySupermarket)] <- 
	+available(beer,fridge);
	-ordered(beer).

// when the fridge is opened, the beer stock is perceived
// and thus the available belief is updated
+stock(beer,0) :  available(beer,fridge) <-
	-available(beer,fridge).
+stock(beer,N) :  N > 0 & not available(beer,fridge) <-
	-+available(beer,fridge).

+?time(T) : true
  <-  time.check(T).

<<<<<<< Updated upstream
/*
-!bringBeer : true <-
	.current_intention(I);
	.println("Failed to achieve goal '!bring(owner,beer)'.");
	.println("Current intention is: ", I).
*/
=======
>>>>>>> Stashed changes
