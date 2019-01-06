# Proj2

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `proj2` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:proj2, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/proj2](https://hexdocs.pm/proj2).


Distributed Operating Systems Project 2 - Gossip Simulator
------------------------------
Team Members-

Aditya Dutt 14530933
Richa Dutt 83877619
------------------------------
How to run-
1. Go inside directory using: cd proj2
2. Now, to compile write: mix compile 
3. To run, use: mix run my_program arg1 arg2 arg3

------------------------------
What is working-

Convergence of Gossip algorithm for all topologies - Full, Line, Imperfect Line, Random 2D, 3D, Sphere 
Convergence of Push Sum algorithm for all topologies - Full, Line, Imperfect Line, Random 2D, 3D, Sphere 

------------------------------
Largest Network - 

Gossip Algorithm:

Line topology - 1000 Nodes
Imperfect Line topology- 2000 nodes
Random2D topology- 3000 nodes
Sphere topology- 2000 nodes
3D topology- 2000 nodes
Full topology- 1000 nodes

Push Sum Algorithm:

Line topology - 1000 Nodes
Imperfect Line topology- 5000 nodes
Random2D topology- 3000 nodes
Sphere topology- 2000 nodes
3D topology- 3000 nodes
Full topology- 2000 nodes

***
Sometimes convergence of full topology takes more time than line, because in line all nodes could not converge but in 
full network most of the nodes gets information so they run until everyone has heard information 10 times. So,full takes more 
time to converge sometimes.
***
