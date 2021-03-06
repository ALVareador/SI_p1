/* Initial beliefs and rules */

actual(1).
mensaje(1,"Cuentame un chiste").
mensaje(2,"Cuentame otro").

/* Initial goals */

!drink(beer).   
!check_bored. 
!geet.

/* Plans */

// if I have not beer finish, in other case while I have beer, sip

+!drink(beer) : ~couldDrink(beer) <-
	.println("Owner ha bebido demasiado por hoy.").	
+!drink(beer) : has(myOwner,beer) & asked(beer) <-
	.println("Owner va a empezar a beber cerveza.");
	-asked(beer);
	sip(beer);
	!drink(beer).
+!drink(beer) : has(myOwner,beer) & not asked(beer) <-
	sip(beer);
	.println("Owner está bebiendo cerveza.");
	!drink(beer).
	 
+!drink(beer) : not has(myOwner,beer) & not asked(beer) <-
	.println("Owner no tiene cerveza.");
	!get(beer);
	!drink(beer).
   
+!drink(beer) : not has(myOwner,beer) & asked(beer) <- 
	.wait(1000);
	.println("Owner está esperando una cerveza.");
	!drink(beer).

+!get(beer) : not asked(beer) <-
	.send(myRobot, achieve, bring(myOwner,beer));
	.println("Owner ha pedido una cerveza al robot.");
	+asked(beer).

////////////////////////////////////////////////////////////////////////////////
 
+!check_bored : true
   <- .random(X); .wait(X*5000+2000);  
     .send(myRobot, askOne, time(_), R); 
      .print(R);
	  !check_bored.
	  
+!geet : actual(Ord) & mensaje(Ord,M) <- .random(X); .wait(X*5000+2000);
	.send(myRobot, tell, new(Ord));
	.send(myRobot, achieve, geet);
	.println(M);
	 !geet. 

 +!geet : actual(Ord) <- 
 +actual(1);
 .abolish(actual(Ord));
 !geet.
 

+new(NewOrd) : actual(Ord) <-
	.abolish(actual(Ord));
	.abolish(new(_));
	+actual(NewOrd);
//	.println("---------------------------------------1");
	if(Ord == 2){
	+actual(1);
	.abolish(actual(Ord));
//	.println("--------------------7");
	};	
	!geet.
	
////////////////////////////////////////////////////////////////////////////////
	
+msg(M)[source(Ag)] <- 
	.print("Message from ",Ag,": ",M);
	+~couldDrink(beer);
	-msg(M).

	

