class Column
    def initialize(_id, _amountOfFloors, _amoutOfElevator)
        @ID = _id
        @status = 'online'
        @elevatorList = []
        @callButtonList = []
        @createElevators(_amountOfFloors, _amoutOfElevator)
        @createCallButtons(_amountOfFloors)
    end

    def self.createCallButtons(_amountOfFloors)
        buttonFloor = 1
        callButtonID = 1
        for i in _amountOfFloors
            if buttonFloor < _amountOfFloors
                callButton = CallButton.new(callButtonID, buttonFloor, "Up")
                @callButtonList += [callButton]
                callButtonID += 1
            end
            if buttonFloor < 1
                callButton = CallButton.new(callButtonID, buttonFloor, "Down")
                @callButtonList += [callButton]
                callButtonID += 1
            end
            buttonFloor += 1
        end
    end
        
    def self.createElevators(_amountOfFloors, _amoutOfElevator)
        elevatorID = 1
        for i in _amoutOfElevator
            elevator = Elevator.new(elevatorID, _amountOfFloors)
            @elevatorList += [elevator]
            elevatorID += 1
        end
    end

    def self.requestElevator(floor, direction)
        elevator = self.findElevator(floor, direction)
        elevator.floorRequestList += [floor]
        elevator.move()
        elevator.operateDoors()
        return elevator
    end
    
    def self.findElevator(requestedFloor, requestedDirection)
        bestElevator = nil
        bestScore = 5
        referenceGap = 10000000

        for elevator in self.elevatorList
            #The elevator is at my floor and going in the direction I want
            if requestedFloor == elevator.currentFloor && elevator.status == "stopped" && requestedDirection == elevator.direction
                bestElevator, bestScore, referenceGap = self.checkIfElevatorIsBetter(1, elevator, bestScore, referenceGap, bestElevator, requestedFloor)
            #The elevator is lower than me, is coming up and I want to go up
            elsif requestedFloor > elevator.currentFloor && elevator.status == "Up" && requestedDirection == elevator.direction:
                bestElevator, bestScore, referenceGap = self.checkIfElevatorIsBetter(2, elevator, bestScore, referenceGap, bestElevator, requestedFloor)
            #The elevator is higher than me, is coming down and I want to go down
            elsif requestedFloor < elevator.currentFloor && elevator.status == "Down" && requestedDirection == elevator.direction:
                bestElevator, bestScore, referenceGap = self.checkIfElevatorIsBetter(2, elevator, bestScore, referenceGap, bestElevator, requestedFloor)
            #The elevator is idle
            elsif elevator.status == "idle":
                bestElevator, bestScore, referenceGap = self.checkIfElevatorIsBetter(3, elevator, bestScore, referenceGap, bestElevator, requestedFloor)
            #The elevator is not available, but still could take the call if nothing better is found
            else
                bestElevator, bestScore, referenceGap = self.checkIfElevatorIsBetter(4, elevator, bestScore, referenceGap, bestElevator, requestedFloor)
            end
        end
        return bestElevator
    end

    def self.checkIfElevatorIsBetter(scoreToCheck, newElevator, bestScore, referenceGap, bestElevator, floor)
        if scoreToCheck < bestScore
            bestScore = scoreToCheck
            bestElevator = newElevator
            referenceGap = (newElevator.currentFloor - floor).abs
        elsif bestScore == scoreToCheck
            gap = (newElevator.currentFloor - floor).abs
            if referenceGap > gap
                bestScore = scoreToCheck
                bestElevator = newElevator
            end
        end 
        return bestElevator, bestScore, referenceGap
    end
end

class Elevator
    def initialize(_id, _amountOfFloors)
        @ID = _id
        @status = ''
        @currentFloor = 1
        @direction = nil
        @door = Door.new(_id)
        @floorRequestButtonList = []
        @floorRequestList = []
        @screenDisplay = []
        @createFloorRequestButtons(_amountOfFloors)
    end

    def self.createFloorRequestButtons(_amountOfFloors)
        buttonFloor = 1
        floorRequestButtonID = 1 
        for i in _amountOfFloors:
            floorRequestButton = FloorRequestButton.new( floorRequestButtonID, buttonFloor)
            @floorRequestButtonList += [floorRequestButton]
            buttonFloor += 1
            floorRequestButtonID += 1
        end
    end

    def self.requestFloor(floor):
        @floorRequestList += [floor]
        self.move()
        self.operateDoors()
    end

    def self.move(self)
        while @floorRequestList != 0 do
            destination = @floorRequestList[0]
            @status = "moving"
            if @currentFloor < destination
                @direction = "Up"
                self.sortFloorList()
                while @currentFloor < destination do
                    @currentFloor += 1
                    @screenDisplay += [@currentFloor]
                end
            elsif @currentFloor > destination:
                @direction = "Down"
                self.sortFloorList()
                while @currentFloor > destination do
                    @currentFloor -= 1
                    @screenDisplay += [@currentFloor]
                end
            end
            @status = "stopped"
            @floorRequestList.shift
        end
        @status = "idle"
        @floorRequestList = []
    end

    def self.operateDoors()
        @door.status = "opened"
        overweight = 350 #kg chosen at random
        obstruction = False #by default there is obstruction
        #time.sleep(5) wait five seconds --> not working
        if overweight < 600
            @door.status = "closing"
            if obstruction == False
                @door.status = "closed"
            else
                self.operateDoors()
            end
        else
            while overweight == True do
                puts "Activate overweight alarm"
            self.operateDoors()
            end
        end
    end
end

class CallButton 
    def initialize(_id, _floor, _direction)
        @ID = _id
        @status = 'OFF'
        @floor = _floor
        @direction = _direction
    end
end

class FloorRequestButton
    def initialize(_id, _floor)
        @ID = _id
        @status = 'OFF'
        @floor = _floor
    end
end

class Door
    def initialize(_id)
        @ID = _id
        @status = 'closed'
    end
end