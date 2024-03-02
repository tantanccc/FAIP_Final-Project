📍Topic: Machine learning assisted topology optimization 
📍Targets:
  ● Create a porous structure from geometry-defining parameters
  ● Optimize the porous structure to minimize the max Von Mises stress
  ● Use Bayesian optimization because the mechanical simulations have long execution times
  ● Combine the individual steps into an automated pipeline that logs the results

📍Description:
  Topology optimization reduces material usage while maintaining performance. A precise but computationally expensive approach to determining performance considers energetic transitions but can be accelerated with machine learning algorithms. The design space is explored efficiently with a Bayesian optimization scheme; AI is used to predict the strength of a given topology.
  
  ● Porespy: Generate PNGs of 2D material structure
  ● MOOSE: Run stress simulations on the structure
  ● BoTorch: Bayesian optimization is used to find the new candidates of parameters that are likely to yield a new optimal von Mises stress
