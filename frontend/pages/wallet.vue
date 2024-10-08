<template>
  <div>
    <Head>
      <Title>Connect your Wallet</Title>
    </Head>
  </div>
  <div class="col min-h-[80vh] md:flex items-center justify-center text-white" style="background-color: #1b1b1b">
    <div
      class="relative md:max-w-lg min-h-screen md:min-h-0 w-full md:mx-auto bg-neutral-800 shadow-lg md:rounded-lg px-8 py-6" style="background-color: rgb(59, 59, 59);">
      <WalletHeader />

      <hr :style="{ margin: '2rem' }" />

      <div :style="{
        display: 'grid',
        gridGap: '1rem',
        gridTemplateColumns: '1fr 1fr',
        maxWidth: '20rem',
        margin: 'auto',
      }">
        <button v-for="(newConnector, name) in connectorsByName"
          class="inline-flex items-center px-4 py-2 border border-transparent text-base font-medium rounded-md text-violet-700 bg-violet-100 hover:bg-violet-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-violet-500"
          :key="name" @click="setActivatingConnector(newConnector)">
          <span class="mr-2" v-if="newConnector === connector" role="img" aria-label="check">
            ✅
          </span>
          <svg v-else-if="activatingConnector === newConnector" class="animate-spin -ml-1 mr-3 h-5 w-5 text-gray-violet"
            xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
            <path class="opacity-75" fill="currentColor"
              d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z">
            </path>
          </svg>

          {{ name }}
        </button>
      </div>

      <div class="flex flex-col items-center mt-8 text-center">
        <button v-if="active"
          class="inline-flex items-center px-4 py-2 border border-transparent text-base font-medium rounded-md text-red-800 bg-red-100 hover:bg-red-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500"
          @click="deactivate">
          Desconectar
        </button>

        <h4 v-if="!!error" :style="{ marginTop: '1rem', marginBottom: '0' }">
          {{ getErrorMessage(error) }}
        </h4>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { UnsupportedChainIdError } from "@instadapp/vue-web3";
import { injected, network, walletconnect } from "~/connectors";
import {
  NoEthereumProviderError,
  UserRejectedRequestError as UserRejectedRequestErrorInjected,
} from "@web3-react/injected-connector";
import { UserRejectedRequestError as UserRejectedRequestErrorWalletConnect } from "@web3-react/walletconnect-connector";

enum ConnectorNames {
  Injected = "Injetada",
  Network = "Rede",
  WalletConnect = "WalletConnect",
}

const connectorsByName: { [connectorName in ConnectorNames]: any } = {
  [ConnectorNames.Injected]: injected,
  [ConnectorNames.Network]: network,
  [ConnectorNames.WalletConnect]: walletconnect,
};

function getErrorMessage(error: Error) {
  if (error instanceof NoEthereumProviderError) {
    return "Nenhuma extensão Ethereum detectada, instale MetaMask no desktop ou visite a partir de um navegador dApp no celular.";
  } else if (error instanceof UnsupportedChainIdError) {
    return "Você está conectado à uma rede não suportada.";
  } else if (
    error instanceof UserRejectedRequestErrorInjected ||
    error instanceof UserRejectedRequestErrorWalletConnect
  ) {
    return "Por favor, autorize este site à acessar sua conta Ethereum.";
  } else {
    console.error(error);
    return "Um erro desconhecido aconteceu. Verifique o console para mais detalhes.";
  }
}

const { active, activate, deactivate, connector, error } = useWeb3();
useEagerConnect();

const activatingConnector = ref();

const setActivatingConnector = async (newConnector: any) => {
  activatingConnector.value = newConnector;
  await activate(newConnector);
  activatingConnector.value = undefined;
};
</script>

<style scoped>
body {
  height: fit-content;
  background-color: #e5e7eb;
}
</style>