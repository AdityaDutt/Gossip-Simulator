defmodule Project2 do
  use GenServer
  @moduledoc """

  This module receives arguments[number of nodes, topology, algorithm] from my_program.ex. For each node,
  genserver is started.Then the network is created according to corresponding topology. This is done in create_topology function.
  After the network is created, each nodes maintains it's count, adjacent neighbors and index in it's state.
  In run_algorithm, our algorithm starts running. One node starts passing the rumor, using genserver. Then, the neighbor and node
  which started it both run concurrently.
  When a node gets count >= 10, it is added in a list i.e., black-listed. If a node has all neighbors with count >= 10, it is also
  blacklisted. Then, if information flow stops at a point or all nodes are blacklisted, we declare it convergence.

  """


 def main(args1,args2,args3) do
        numNodes=args1
        topology=args2
        algorithm=args3

        numNodes=check_topo(topology,numNodes)
        allNodes = Enum.map((1..numNodes), fn(x) ->
        pid=start_node()
        updatePIDState(pid, x)
        pid
        end)

        table = :ets.new(:table, [:named_table,:public])
        :ets.insert(table, {"count",0})

        create_topology(topology,allNodes)
#       :timer.sleep(2)
        startTime = System.monotonic_time(:millisecond)
        startAlgorithm(algorithm, allNodes, startTime,[])
        keep_running(Enum.count(allNodes))
  end

  def check_topo(topo,n) when topo=="sphere" do
     getPerfectSq(n)
  end

  def check_topo(topo,n) when topo=="3D" do
     getNextPerfectCube(n)
  end

  def check_topo(_topo,n) do
     n
  end

  def keep_running(n) do
  keep_running(n)
  end

  def checkEtsTable(numNodes, startTime,table, parent) do

    [{_, currentCount}] = :ets.lookup(table, "count")

    if currentCount == (0.9*numNodes) do
      currentTime = System.system_time(:millisecond)
      endTime = currentTime - startTime
      IO.puts "Convergence Achieved in = "<> Integer.to_string(endTime)
      Process.exit(parent, :kill)
    end
    checkEtsTable(numNodes,startTime, table, parent)
   end

  def create_topology(topology,allNodes) do
    case topology do
      "full" ->buildFull(allNodes)
      "sphere" ->buildSphere(allNodes)
      "line" ->buildLine(allNodes)
      "impline" ->buildimpLine(allNodes)
      "rand2D" ->buildRandom2D(allNodes)
       "3D"->build3D(allNodes)
       _ -> IO.puts("Wrong argument")
               System.halt(0)
    end
  end

  def buildFull(allNodes) do

    Enum.each(allNodes, fn(k) ->
      adjList=List.delete(allNodes,k)
      updateAdjacentListState(k,adjList)
    end)
  end


  def getPerfectSq(numNodes) do
    round :math.pow(:math.ceil(:math.sqrt(numNodes)) ,2)
  end

  def getNextPerfectCube(numNodes) do
    power =1/3
   round :math.pow(:math.ceil(:math.pow(numNodes,power)) ,3)
  end

  def build3D(allNodes) do
         numNodes=Enum.count(allNodes)
         power=1/3
         dim =  round :math.ceil(:math.pow(numNodes,power))
         zMax = dim # truncates the cuberoot values nearest integer i.e 2.99 gets truncated to 2
         xMax = zMax
         yMax = zMax
         zMulti = round( :math.pow(xMax,2))
         yMulti = xMax
         x_max = xMax - 1
         y_max = yMax - 1
         z_max = zMax - 1
        for z <- 0 .. z_max do
          for y <-0  .. y_max do
            for x<-0 .. x_max do
              i = dim*dim*z + dim*y + x
              if i < numNodes do
                 gossiper = Enum.at(allNodes,i)
                 adjList = []
                if x > 0 do
                   neighbours = Enum.fetch!(allNodes,i - 1)
                   adjList = adjList ++ [neighbours]
                   updateAdjacentListState(gossiper,adjList)
                 end
                if x < x_max && (i + 1) < numNodes do
                  neighbours = Enum.fetch!(allNodes,i + 1)
                  adjList = adjList ++ [neighbours]
                  updateAdjacentListState(gossiper,adjList)
                end
                if y > 0 do
                   neighbours = Enum.fetch!(allNodes,i - yMulti)
                   adjList = adjList ++ [neighbours]
                   updateAdjacentListState(gossiper,adjList)
                 end
                if y < y_max && (i + yMulti) < numNodes do
                  neighbours = Enum.fetch!(allNodes,i + yMulti)

                  adjList = adjList ++ [neighbours]
                  updateAdjacentListState(gossiper,adjList)
                 end
                if z > 0 do
                  neighbours = Enum.fetch!(allNodes,i - zMulti)

                  adjList = adjList ++ [neighbours]
                  updateAdjacentListState(gossiper,adjList)
                 end
                if z < z_max && (i + zMulti) < numNodes do
                  neighbours = Enum.fetch!(allNodes,i + zMulti)

                  adjList = adjList ++ [neighbours]
                  updateAdjacentListState(gossiper,adjList)
                  end

              end
            end
          end
        end
  end

  def buildSphere(allNodes) do
    numNodes=Enum.count allNodes
    numNodesSQR= :math.sqrt numNodes

    Enum.each(allNodes, fn(k) ->
      adjList=[]
      count=Enum.find_index(allNodes, fn(x) -> x==k end)

      if(!isNodeBottom(count,numNodes)) do
        index=count + round(numNodesSQR)
        neighbhour1=Enum.fetch!(allNodes, index)
        adjList = adjList ++ [neighbhour1]
        updateAdjacentListState(k,adjList)
      end

      if(!isNodeTop(count,numNodes)) do
        index=count - round(numNodesSQR)
        neighbhour2=Enum.fetch!(allNodes, index)
        adjList = adjList ++ [neighbhour2]
        updateAdjacentListState(k,adjList)
      end

      if(!isNodeLeft(count,numNodes)) do
        index=count - 1
        neighbhour3=Enum.fetch!(allNodes,index )
        adjList = adjList ++ [neighbhour3]
        updateAdjacentListState(k,adjList)
       end

      if(!isNodeRight(count,numNodes)) do
        index=count + 1
        neighbhour4=Enum.fetch!(allNodes, index)
        adjList = adjList ++ [neighbhour4]
        updateAdjacentListState(k,adjList)
      end
    end)
    row = round(numNodesSQR)
    Enum.each(1..row, fn x-> y = x + row*(row-1)
                                  neighbourn1= Enum.fetch!(allNodes,x-1)
                                  neighbourn2= Enum.fetch!(allNodes,y-1)
                                  adjList1 = [neighbourn1]
                                  adjList2 = [neighbourn2]
                                  updateAdjacentListState(Enum.at(allNodes,y-1),adjList1)
                                  updateAdjacentListState(Enum.at(allNodes,x-1),adjList2)


    end)

   col = Enum.map(1..row, fn x->  x + (x-1)*(row-1) end)
        Enum.each(col, fn x-> y = x + row-1
                                      neighbourn1= Enum.fetch!(allNodes,x-1)
                                      neighbourn2= Enum.fetch!(allNodes,y-1)
                                      adjList1 = [neighbourn1]
                                      adjList2 = [neighbourn2]
                                      updateAdjacentListState(Enum.at(allNodes,y-1),adjList1)
                                      updateAdjacentListState(Enum.at(allNodes,x-1),adjList2)


        end)

  end

    def buildimpLine(allNodes) do

      numNodes=Enum.count allNodes
      Enum.each(allNodes, fn(k) ->
        count=Enum.find_index(allNodes, fn(x) ->x==  k end)
        tempList = allNodes
        cond do
          numNodes==count+1 ->
            neighbhour1=Enum.fetch!(allNodes, count - 1)
            adjList=[neighbhour1]#,neighbhour2]
            updateAdjacentListState(k,adjList)

            tempList=List.delete_at(tempList, count)
            tempList=List.delete_at(tempList, count-1)

            neighbhourn=Enum.random(tempList)
            adjList =  [neighbhourn]
            updateAdjacentListState(k,adjList)

          0==count ->
              neighbhour1=Enum.fetch!(allNodes, count+1 )
              #neighbhour2=List.first (allNodes)
              adjList=[neighbhour1]#,neighbhour2]
              updateAdjacentListState(k,adjList)

              tempList=List.delete_at(tempList, count)
              tempList=List.delete_at(tempList, count+1)

              neighbhourn=Enum.random(tempList)
              adjList =  [neighbhourn]
              updateAdjacentListState(k,adjList)
          true ->
            neighbhour1=Enum.fetch!(allNodes, count + 1)
            neighbhour2=Enum.fetch!(allNodes, count - 1)
            adjList=[neighbhour1,neighbhour2]
            updateAdjacentListState(k,adjList)

            tempList=List.delete_at(tempList, count)
            tempList=List.delete_at(tempList, count-1)
            tempList=List.delete_at(tempList, count+1)


            neighbhourn=Enum.random(tempList)
            adjList =  [neighbhourn]
            updateAdjacentListState(k,adjList)
        end

      end)
    end

  def buildLine(allNodes) do

    numNodes=Enum.count allNodes
    Enum.each(allNodes, fn(k) ->
      count=Enum.find_index(allNodes, fn(x) -> x==k end)

      cond do
        numNodes==count+1 ->
          neighbhour1=Enum.fetch!(allNodes, count - 1)
          adjList=[neighbhour1]#,neighbhour2]
          updateAdjacentListState(k,adjList)

        0==count ->
            neighbhour1=Enum.fetch!(allNodes, count+1 )
            adjList=[neighbhour1]#,neighbhour2]
            updateAdjacentListState(k,adjList)
        true ->
          neighbhour1=Enum.fetch!(allNodes, count + 1)
          neighbhour2=Enum.fetch!(allNodes, count - 1)
          adjList=[neighbhour1,neighbhour2]
          updateAdjacentListState(k,adjList)
      end

    end)
  end


  def buildRandom2D(allNodes) do

    numNodes=Enum.count allNodes
    rowcnt = round(:math.sqrt(numNodes))
    neighboursList=[]
         for i <- 1..numNodes do
              cond do
                                     i == 1 -> neighboursList = neighboursList ++ [i+1,i+rowcnt]
                                     adjacentList = Enum.map(neighboursList, fn x->Enum.fetch!(allNodes,x-1) end)
                                     updateAdjacentListState(Enum.at(allNodes,i-1),adjacentList)

                                     i == rowcnt -> neighboursList=  neighboursList ++ [i-1,i+rowcnt]
                                     adjacentList = Enum.map(neighboursList, fn x->Enum.fetch!(allNodes,x-1) end)
                                     updateAdjacentListState(Enum.at(allNodes,i-1),adjacentList)

                                     i == numNodes - rowcnt + 1 -> neighboursList=  neighboursList ++ [i+1,i-rowcnt]
                                     adjacentList = Enum.map(neighboursList, fn x->Enum.fetch!(allNodes,x-1) end)
                                     updateAdjacentListState(Enum.at(allNodes,i-1),adjacentList)

                                     i == numNodes ->neighboursList=  neighboursList ++ [i-1,i-rowcnt]
                                     adjacentList = Enum.map(neighboursList, fn x->Enum.fetch!(allNodes,x-1) end)
                                     updateAdjacentListState(Enum.at(allNodes,i-1),adjacentList)

                                     i < rowcnt -> neighboursList=  neighboursList ++ [i-1,i+1,i+rowcnt]
                                     adjacentList = Enum.map(neighboursList, fn x->Enum.fetch!(allNodes,x-1) end)
                                     updateAdjacentListState(Enum.at(allNodes,i-1),adjacentList)

                                     i > numNodes - rowcnt + 1 && i < numNodes ->neighboursList=  neighboursList ++ [i-1,i+1,i-rowcnt]
                                     adjacentList = Enum.map(neighboursList, fn x->Enum.fetch!(allNodes,x-1) end)
                                     updateAdjacentListState(Enum.at(allNodes,i-1),adjacentList)

                                     rem(i-1,rowcnt) == 0 -> neighboursList=  neighboursList ++ [i+1,i-rowcnt,i+rowcnt]
                                     adjacentList = Enum.map(neighboursList, fn x->Enum.fetch!(allNodes,x-1) end)
                                     updateAdjacentListState(Enum.at(allNodes,i-1),adjacentList)

                                     rem(i,rowcnt) == 0 ->neighboursList =  neighboursList ++ [i-1,i-rowcnt,i+rowcnt]
                                     adjacentList = Enum.map(neighboursList, fn x->Enum.fetch!(allNodes,x-1) end)
                                     updateAdjacentListState(Enum.at(allNodes,i-1),adjacentList)

                                     true ->neighboursList=  neighboursList ++ [i-1,i+1,i-rowcnt,i+rowcnt]
                                     adjacentList = Enum.map(neighboursList, fn x->Enum.fetch!(allNodes,x-1) end)
                                     updateAdjacentListState(Enum.at(allNodes,i-1),adjacentList)

                               end
                 end
  end



  def buildImp2D (allNodes) do

    numNodes=Enum.count allNodes
    numNodesSQR = :math.sqrt numNodes
    Enum.each(allNodes, fn(k) ->
      adjList=[]
      tempList=allNodes
      count=Enum.find_index(allNodes, fn(x) -> x==k end)
      if(!isNodeBottom(count,numNodes)) do
        index=count + round(numNodesSQR)
        neighbhour1=Enum.fetch!(allNodes, index)
        adjList = adjList ++ [neighbhour1]
        tempList=List.delete_at(tempList, index)
        neighbhour5=Enum.random(tempList)
        adjList = adjList ++ [neighbhour5]
        updateAdjacentListState(k,adjList)
      end

      if(!isNodeTop(count,numNodes)) do
        index=count - round(numNodesSQR)
        neighbhour2=Enum.fetch!(allNodes, index)
        adjList = adjList ++ [neighbhour2]
        tempList=List.delete_at(tempList, index)
        neighbhour5=Enum.random(tempList)
        adjList = adjList ++ [neighbhour5]
        updateAdjacentListState(k,adjList)

      end

      if(!isNodeLeft(count,numNodes)) do
        neighbhour3=Enum.fetch!(allNodes, count - 1)
        adjList = adjList ++ [neighbhour3]
        tempList=List.delete_at(tempList, count - 1)
        neighbhour5=Enum.random(tempList)
        adjList = adjList ++ [neighbhour5]
        updateAdjacentListState(k,adjList)
      end

      if(!isNodeRight(count,numNodes)) do
        neighbhour4=Enum.fetch!(allNodes, count + 1)
        adjList = adjList ++ [neighbhour4]
        tempList=List.delete_at(tempList, count + 1)
        neighbhour5=Enum.random(tempList)
        adjList = adjList ++ [neighbhour5]
        updateAdjacentListState(k,adjList)
      end

    end)
  end


  def isNodeBottom(i,length) do
    if(i>=(length-(:math.sqrt length))) do
      true
    else
      false
    end
  end

  def isNodeTop(i,length) do
    if(i< :math.sqrt length) do
      true
    else
      false
    end
  end

  def isNodeLeft(i,length) do
    if(rem(i,round(:math.sqrt(length))) == 0) do
      true
    else
      false
    end
  end

  def isNodeRight(i,length) do
    if(rem(i + 1,round(:math.sqrt(length))) == 0) do
      true
    else
      false
    end
  end
  @doc """
    This function starts algorithm of choice.
  """
  def startAlgorithm(algorithm,allNodes, startTime,added) do
    case algorithm do
      "gossip" -> startGossip(allNodes, startTime,added)
      "push-sum" ->start_push_sum(allNodes, startTime)
    end
  end
  @doc """
    This function starts gossip algorithm by first chosing random node and giving information to it.
  """

  def startGossip(allNodes, startTime,added) do
    chosenFirstNode = Enum.random(allNodes)
    updateCountState(allNodes,chosenFirstNode, startTime, length(allNodes))
    recurse_gossip(allNodes,chosenFirstNode, startTime, length(allNodes),added)

  end
  @doc """
    This function check if the neighbor of node is black listed or not before sending info to it.
  """
  def check_con(n,l,len,nodes,startTime) do
    #IO.puts("con")
   l=Enum.filter(l,fn x->getCountState(x) < 10 end )
   if length(l) == 0 do
     add1(len,nodes,l,startTime)
     add(len,nodes,n,startTime)

  end
  l
  end
  @doc """
  This function keeps running gossip using genserver. If the process has count>=10, it is not alive anymore, it exits
  """
  def recurse_gossip(allNodes,chosenRandomNode, startTime, total,added) do
    node_count = getCountState(chosenRandomNode)

    if  node_count < 11 do
        adjacentList = getAdjacentList(chosenRandomNode)
        chosenRandomAdjacentL=check_con(chosenRandomNode,adjacentList,Enum.count(allNodes),allNodes,startTime)
        if length(chosenRandomAdjacentL) == 0 do
          Process.exit(chosenRandomNode,:normal)

        else
          if(Process.alive?(chosenRandomNode)) do
          chosenRandomAdjacent = Enum.random(chosenRandomAdjacentL)
          Task.start(Project2,:receiveMessage,[allNodes,chosenRandomAdjacent, startTime, total,added])
          recurse_gossip(allNodes,chosenRandomNode, startTime, total,added)
end

        end

      else
        Process.exit(chosenRandomNode, :normal)
    end
    if Process.alive?(chosenRandomNode) do
     recurse_gossip(allNodes,chosenRandomNode, startTime, total,added)
    end

  end
  @doc """
  This function starts push-sum. It chooses random node to start with, then starts algorithm using genserver.
  """
  def start_push_sum(allNodes, startTime) do
    chosenFirstNode = Enum.random(allNodes)
    GenServer.cast(chosenFirstNode, {:ReceivePushSum,0,0,startTime, length(allNodes)})
  end

  def change_count(diff, x, c) when diff < x when c < 2 do
   c= c + 1
   c
  end
  def change_count(diff, x,_c) when diff > x do
   0
  end
  def change_count(_diff,_x, c)  do
   c
  end


  def handle_cast({:ReceivePushSum,incomingS,incomingW,startTime, total_nodes},state) do

    {s,pscount,adjList,w} = state

    myS = s + incomingS
    myW = w + incomingW

    difference = abs((myS/myW) - (s/w))

    if(difference < :math.pow(10,-10) && pscount==2) do
      count = :ets.update_counter(:table, "count", {2,1})
      if count == total_nodes do
        endTime = System.monotonic_time(:millisecond) - startTime
        IO.puts "Convergence reached in #{endTime} Milliseconds"
        System.halt(0)
      end
    end

    xm = :math.pow(10,-10)
    pscount = change_count(difference, xm,pscount)
    state = {myS/2,pscount,adjList,myW/2}

    randomNode = Enum.random(adjList)
    sendPushSum(randomNode, myS/2, myW/2,startTime, total_nodes)
    {:noreply,state}
  end

  def sendPushSum(randomNode, myS, myW,startTime, total_nodes) do
    GenServer.cast(randomNode, {:ReceivePushSum,myS,myW,startTime, total_nodes})
  end

  def updatePIDState(pid,nodeID) do
    GenServer.call(pid, {:UpdatePIDState,nodeID})
  end

  def handle_call({:UpdatePIDState,nodeID}, _from ,state) do
    {a,b,c,d} = state
    state={nodeID,b,c,d}
    {:reply,a, state}
  end

  def updateAdjacentListState(pid,map) do
    GenServer.call(pid, {:UpdateAdjacentState,map})
  end

  def handle_call({:UpdateAdjacentState,map}, _from, state) do
    {a,b,c,d}=state
     c = c ++ map
    state={a,b,c,d}
    {:reply,a, state}
  end

  def updateCountState(allNodes,pid, startTime, total) do

      GenServer.call(pid, {:UpdateCountState,allNodes,startTime, total})

  end



  def handle_call({:UpdateCountState,_allNodes,_startTime,_total},from,state) do
    {a,b,c,d}=state

    if b==0 do
      if  :ets.insert_new(:table, {"node", from}) == true do
          :ets.update_counter(:table, "count", {2,1})
      end
    end

    state={a,b+1,c,d}
    {_a,b,_c,_d}=state
    {:reply,b,state}
  end


  def getCountState(pid) do
    GenServer.call(pid,{:GetCountState})
  end

  def getIndex(pid) do
    GenServer.call(pid,{:GetIndex})
  end

  def handle_call({:GetCountState}, _from ,state) do
    {_a,b,_c,_d}=state
    {:reply,b, state}
  end

  def handle_call({:GetIndex}, _from ,state) do
    {a,_b,_c,_d}=state
    {:reply,a, state}
  end

  def receiveMessage(allNodes,pid, startTime, total,added) do
     updateCountState(allNodes,pid, startTime, total)

     recurse_gossip(allNodes,pid, startTime, total,added)
  end


  def add1(_total,_nodes,n,_startTime) do

    Enum.each(n,fn x->     if :ets.insert_new(:table, {"node", x}) == true do
      :ets.update_counter(:table, "count", {2,1}
      )
      Process.exit(x,:normal)

    end  end)

  end

 def add(total,nodes,n,startTime) do
  x =  :ets.lookup(:table, "node")
  :ets.insert(:table, {"node", n})

  p = length(x)
  y =  :ets.lookup(:table, "node")
  p1 = length(y)

  if p1 > p do
     :ets.update_counter(:table, "count", {2,1})
  end

  rem = nodes -- y
  #l = Enum.filter(rem,fn x->getCountState(x) >= 10 end )
  #sum = p1 + length(l)
  rem=Enum.sort(rem)
  l = Enum.filter(rem,fn x->getCountState(x) ==0  end )
  l1=Enum.map(l,fn x -> getIndex(x) end)
  l2 = Enum.map(l1,fn x->x-1 end )
  l3= l1 -- l2
  len_l3=length(l3)
  len_l1=length(l1)

  [{_,count}] = :ets.lookup(:table, "count")

  l = Enum.filter(nodes,fn x->getCountState(x) >= 10 end )
  con = length(l)
  #IO.puts("Nodes : #{con}")
  if count >=total/2 && count<=total || con >=total/2 && con<=total || (len_l1 - len_l3) ==0 do
          endTime = System.monotonic_time(:millisecond) - startTime
              x= div(Enum.random(10..1000),4)
              :timer.sleep(x)
#   IO.puts("Nodes : #{con} converged out of #{total}")
    IO.puts("Convergence reached in #{endTime} milliseconds")
    System.halt(0)
 end

end

  def check_num(a,b) do
    if a>0 && b==0 || a==0 && b>0 do
      0
    else 1
    end
  end

  def check_con(list,n,d) when n>1  do
    a= Enum.at(list,n)
    b= Enum.at(list,n-1)
    d = d + check_num(a,b)
    check_con(list,n-1,d)
    d
  end

  def check_con(list,n,d) when n<=1 do
    a= Enum.at(list,n)
    b= Enum.at(list,n-1)
    d = d + check_num(a,b)

    d
  end

  def status_report(nodes) do
     Enum.each(1..Enum.count(nodes),fn x-> GenServer.call(Enum.at(nodes,x-1),{:GetAll})  end)
  end

  def change_neighbor(nodes,pid) do
    nodes = List.delete(nodes,pid)
    Enum.each(nodes,fn x-> GenServer.call(x,{:Change,pid})  end)

  end


  def getAdjacentList(pid) do
    GenServer.call(pid,{:GetAdjacentList})
  end
  def start_node() do
    {:ok,pid}=GenServer.start_link(__MODULE__, :ok,[])
    pid
  end

  def handle_call({:GetAll},_from,state) do
    {_a,b,_c,_d}=state
#     IO.puts("state #{inspect(state)}")
    {:reply,b, state}
  end

  def init(:ok) do
    {:ok, {0,0,[],1}}
  end

  def handle_call({:Change,pid},_from,state) do
    {a,b,c,d}=state
    c = List.delete(c,pid)
    state = {a,b,c,d}

    {:reply,c, state}
  end

  def handle_call({:GetAdjacentList}, _from ,state) do
    {_a,_b,c,_d}=state
    {:reply,c, state}
  end



end
