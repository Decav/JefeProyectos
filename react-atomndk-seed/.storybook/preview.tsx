import { PrimeReactProvider } from 'primereact/api';
import type { Preview } from '@storybook/react-vite';
import '../src/styles/main.css';
import '../src/styles/theme.css';
import 'primeicons/primeicons.css';

const preview: Preview = {
  parameters: {
    controls: { matchers: { color: /(background|color)$/i, date: /Date$/i } },
  },
  decorators: [
    (Story) => (
      <PrimeReactProvider>
        <Story />
      </PrimeReactProvider>
    ),
  ],
};

export default preview;
