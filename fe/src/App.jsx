import { Button, ButtonGroup, SliderField } from '@aws-amplify/ui-react';
import { useRef, useState } from 'react';
import '@aws-amplify/ui-react/styles.css';
import Plotly from 'plotly.js/dist/plotly';

function App() {
  const burntTrees = useRef([]);
  let [location, setLocation] = useState("");
  let [gridSize, setGridSize] = useState(20);
  let [simSpeed, setSimSpeed] = useState(2);
  let [simDensity, setSimDensity] = useState(0.6);
  let [simSpread, setSimSpread] = useState(50);
  let [southWind, setSouthWind] = useState(0);
  let [westWind, setWestWind] = useState(0);
  let [trees, setTrees] = useState([]);

  const running = useRef(null);

  const setup = () => {
    fetch("http://localhost:8000/simulations", {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ dim: [gridSize, gridSize], density: simDensity, spread: simSpread, winds: [southWind, westWind] })
    }).then(resp => resp.json())
    .then(data => {
      setLocation(data["Location"]);
      setTrees(data["trees"]);
    });
  };

  const handleStart = () => {
    burntTrees.current = [];
    running.current = setInterval(() => {
      fetch("http://localhost:8000" + location)
      .then(res => res.json())
      .then(data => {
        let burnt = data["trees"].filter(t => t.status === "burnt").length / data["trees"].length;
        burntTrees.current.push(burnt);
        setTrees(data["trees"]);
      });
    }, 1000 / simSpeed);
  };

  const handleStop = () => {
    clearInterval(running.current);
    Plotly.newPlot('mydiv', [{
      y: burntTrees.current,
      mode: 'lines+markers',
      type: 'scatter',
      line: { color: '#FF5733' }
    }]);
  };

  return (
    <div>
      <h1>Forest Fire Simulation</h1>
      <ButtonGroup>
        <Button onClick={setup}>Initialize</Button>
        <Button onClick={handleStart}>Begin</Button>
        <Button onClick={handleStop}>Halt</Button>
      </ButtonGroup>
      <SliderField label="Simulation Speed" min={1} max={40} step={1} value={simSpeed} onChange={setSimSpeed} />
      <SliderField label="Grid Size" min={10} max={50} step={5} value={gridSize} onChange={setGridSize} />
      <SliderField label="Tree Density" min={0.1} max={0.9} step={0.05} value={simDensity} onChange={setSimDensity} />
      <SliderField label="Spread Probability" min={0} max={100} step={1} value={simSpread} onChange={setSimSpread} />
      <SliderField label="South Wind Speed" min={-50} max={50} step={1} value={southWind} onChange={setSouthWind} />
      <SliderField label="West Wind Speed" min={-50} max={50} step={1} value={westWind} onChange={setWestWind} />

      <div id="mydiv" style={{ width: '100%', height: '400px' }}></div>
    </div>
  );
}

export default App;