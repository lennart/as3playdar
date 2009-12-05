# as3playdar

## To use
Copy the [as3playdar.swc](http://github.com/imlucas/as3playdar/blob/master/bin/as3playdar.swc) into the libs directory of your Flex project.

## Quick Examples

### Basic Resolve and play

    import org.playdar.Playdar;
    var playdar:Playdar = new Playdar();
    playdar.resolve(
        "Massive Attack",
        "Angel",
        function(r:Object):void{
            playdar.play(r.results[0].sid);
        }, 
        function(e:Error):void{
            trace('Error occurred while resolving: '+e.message);
        }
    );

### Checking if playdar is available

    import org.playdar.Playdar;    
    var playdar:Playdar = new Playdar();
    playdar.status(
        function(r:Object):void{
            trace("Playdar is available and its running version "+r.version);
        },
        function(e:Error):void{
            trace("Playdar is unavailable");
        }
    );
    