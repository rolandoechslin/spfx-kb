// Source: https://joaojmendes.com/2021/01/02/get-user-information-and-photo-using-msgraph-batch/
// Source: https://github.com/ValoIntranet/indexeddb-cache

import { User } from "@microsoft/microsoft-graph-types";
import { ServiceScope } from "@microsoft/sp-core-library";
import {
  MSGraphClient,
  MSGraphClientFactory
} from "@microsoft/sp-http";
import { PageContext } from "@microsoft/sp-page-context";
import { CacheService } from "@valo/cache";

export interface IUserInfo extends User {
  userPhoto: string;
}

export interface IBatchRequest {
  id: string;
  method: "GET" | "PUT" | "POST" | "DELETE" | "PATCH" | "OPTIONS";
  url: string;
  body?: any;
  headers?: any;
}

export const useUsers = (serviceScope: ServiceScope) => {
  let _pageContext: PageContext = undefined;
  let _msgGraphclient: MSGraphClient = undefined;


  serviceScope.whenFinished(async () => {
    _pageContext = serviceScope.consume(PageContext.serviceKey);
    _msgGraphclient = await serviceScope
      .consume(MSGraphClientFactory.serviceKey)
      .getClient();

    await cache.init();
  });
  const cache = new CacheService(`user_${_pageContext.user.email}`);

 // Convert Blog to Base64
 const  blobToBase64 = (blob: Blob): Promise<string> => {
    return new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.onerror = reject;
      reader.onload = _ => {
        resolve(reader.result as string);
      };
      reader.readAsDataURL(blob);
    });
  };

  // Convert Binary to Blob
   const b64toBlob = async (b64Data:any, contentType:string, sliceSize?:number):Promise<Blob>  => {
    contentType = contentType || 'image/png';
    sliceSize = sliceSize || 512;

    let byteCharacters:string = atob(b64Data);
    let byteArrays = [];

    for (let offset = 0; offset < byteCharacters.length; offset += sliceSize) {
      let slice = byteCharacters.slice(offset, offset + sliceSize);

      let byteNumbers = new Array(slice.length);
      for (let i = 0; i < slice.length; i++) {
          byteNumbers[i] = slice.charCodeAt(i);
      }

      let byteArray = new Uint8Array(byteNumbers);
      byteArrays.push(byteArray);
    }

    let blob = new Blob(byteArrays, {type: contentType});
    return blob;
  };
  /**
   *  Get User Info
   * @param user
   */
  const getUser = async (user: string): Promise<IUserInfo> => {
    let userInfo: IUserInfo;
    let blobPhoto: string;
    let usersResults: User;
    // Create a Batch Request
    // 2 rquests
    // id=1 = user Info
    // id=2 = user Photo
    const batchRequests: IBatchRequest[] = [
      {
        id: "1",
        url: `/users/${user}`,
        method: "GET",
        headers: {
          ConsistencyLevel: "eventual",
        },
      },
      {
        id: "2",
        url: `/users/${user}/photo/$value`,
        headers: { "content-type": "img/jpg" },
        method: "GET",
      },
    ];

    // Try to get user information from cache
    try {
      userInfo = await cache.get(`${user}`);
      return userInfo;
    } catch (error) {
      // execute batch
      const batchResults: any = await _msgGraphclient
        .api(`/$batch`)
        .version("v1.0")
        .post({ requests: batchRequests });

      // get Responses
      const responses: any = batchResults.responses;
      // load responses
      for (const response of responses) {

        switch (response.id) {
            // user info
          case "1":
            usersResults = response.body;
            break;
              // user photo
          case "2":
            const binToBlob = response?.body
              ? await b64toBlob(response?.body, "img/jpg")
              : undefined;
            blobPhoto = (await blobToBase64(binToBlob)) ?? undefined;
            break;
          default:
            break;
        }
      }
      // save userinfo in cache
      userInfo = { ...usersResults, userPhoto: blobPhoto };
      // return Userinfo with photo
      await cache.put(`${user}`, userInfo);
      return userInfo;
    }
  };

  return {
    getUser,
  };
};