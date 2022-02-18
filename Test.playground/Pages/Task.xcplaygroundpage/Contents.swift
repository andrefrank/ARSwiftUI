import UIKit
import PlaygroundSupport

//Need infinite run here
PlaygroundPage.current.needsIndefiniteExecution = true

//The method which only runs on main thread and returns with a completion handler
@MainActor func snapshot(save:Bool,completion:@escaping(Int)->Void){
    //The mockup return value
    let retVal = 5
    
    //Delay completion handler and return with mock value
    print("Global dispatch entry call - Now wait for the result")
    DispatchQueue.global().asyncAfter(deadline: .now()+4) {
        
        completion(retVal)
        print("Global dispatch method exit with return value:")
    }
}

//Testing asynchronous call but do it on main thread which may crash the app
// We will see soon...
@MainActor func test() async -> Int {
    //Define a task which only returns the mock value
    let imageTask:Task<Int,Never> = Task {
        //The continuation will serialize the completion handler
        let mockValue:Int =  await withCheckedContinuation { continuation in
            //Call original method to isolate completion handler
            snapshot(save: true) { value in
                //Resuming continuation will give exit the completion handler
                continuation.resume(returning: value)
            }
        }
        
        //Now the mock value is present
        return mockValue
    }
    
    //Make an asynchronous call to get the value
    return await imageTask.value
    
}


// ###########################  Test phase #####################
Task {
        let value = await test()
        print(value)
}
