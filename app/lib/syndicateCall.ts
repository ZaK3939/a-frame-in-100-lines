import { Address, Hex } from "viem";
import { NFT_ADDRESS } from "../config";

export async function syndicateCallForSigMint(
  messageBytes: string,
  address: Address,
  fid: number,
  sig: Hex,
) {
  let functionSignature = "mint(address,uint256,uint256,bytes)";
  const postData = JSON.stringify({
    frameTrustedData: messageBytes,
    contractAddress: NFT_ADDRESS,
    functionSignature: functionSignature,
    args: [address, 1, fid, sig],
    shouldLike: false,
    shouldRecast: true,
    shouldFollow: false,
  });
  const res = await fetch("https://frame.syndicate.io/api/v2/sendTransaction", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${process.env.SYNDICATE_API_KEY}`,
    },
    body: postData,
  });
  return res;
}

export async function checkTransactionIdStatus(transactionId: string) {
  const res = await fetch(
    `https://frame.syndicate.io/api/v2/transaction/${transactionId}/hash`,
    {
      headers: {
        "content-type": "application/json",
        Authorization: `Bearer ${process.env.SYNDICATE_API_KEY}`,
      },
    },
  );
  return res;
}